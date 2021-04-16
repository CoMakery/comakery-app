require 'rails_helper'
require 'models/concerns/synchronisable_spec'

RSpec.describe OreIdAccount, type: :model, vcr: true do
  it_behaves_like 'synchronisable'

  before { allow_any_instance_of(described_class).to receive(:sync_allowed?).and_return(true) }

  subject { create(:ore_id, skip_jobs: true) }

  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_many(:wallets).dependent(:destroy) }
  it { is_expected.to validate_uniqueness_of(:account_name) }
  it { is_expected.to define_enum_for(:state).with_values({ pending: 0, pending_manual: 1, unclaimed: 2, ok: 3, unlinking: 4 }) }

  context 'when transitioning between states' do
    before do
      allow(subject).to receive(:create_account)
      allow(subject).to receive(:pull_wallets)
      allow(subject).to receive(:push_wallets)
      allow(subject).to receive(:sync_opt_ins)
      allow(subject).to receive(:sync_password_update)
    end

    it { is_expected.to transition_from(:pending).to(:unclaimed).on_event(:create_remote) }
    it { is_expected.to transition_from(:unclaimed).to(:unclaimed).on_event(:sync_remote) }
    it { is_expected.to transition_from(:pending_manual).to(:ok).on_event(:sync_remote) }
    it { is_expected.to transition_from(:ok).to(:ok).on_event(:sync_remote) }
    it { is_expected.to transition_from(:pending).to(:unlinking).on_event(:unlink) }
    it { is_expected.to transition_from(:unclaimed).to(:ok).on_event(:claim) }
  end

  context 'before_create' do
    specify { expect(subject.temp_password).not_to be_empty }
  end

  context 'after_create' do
    subject { described_class.new(account: create(:account), id: 99999) }

    it 'schedules a sync' do
      expect(OreIdSyncJob).to receive(:perform_later).with(subject.id)
      subject.save
    end

    context 'for pending_manual state' do
      subject { described_class.new(account: create(:account), id: 99999, state: :pending_manual) }

      it 'doesnt schedule a sync' do
        expect(OreIdSyncJob).not_to receive(:perform_later).with(subject.id)
        subject.save
      end
    end
  end

  describe '#create_remote!' do
    specify do
      expect(subject).to receive(:create_account)
      expect(subject).to receive(:pull_wallets)
      expect(subject).to receive(:push_wallets)
      expect(subject).to receive(:sync_opt_ins)
      subject.create_remote!
      expect(subject).to be_unclaimed
    end
  end

  describe '#sync_remote!' do
    context 'when unclaimed' do
      before do
        subject.unclaimed!
      end

      specify do
        expect(subject).to receive(:pull_wallets)
        expect(subject).to receive(:push_wallets)
        expect(subject).to receive(:sync_opt_ins)
        subject.sync_remote!
        expect(subject).to be_unclaimed
      end
    end

    context 'when pending_manual' do
      before do
        subject.pending_manual!
      end

      specify do
        expect(subject).to receive(:pull_wallets)
        expect(subject).to receive(:push_wallets)
        expect(subject).to receive(:sync_opt_ins)
        subject.sync_remote!
        expect(subject).to be_ok
      end
    end

    context 'when ok' do
      before do
        subject.ok!
      end

      specify do
        expect(subject).to receive(:pull_wallets)
        expect(subject).not_to receive(:push_wallets)
        expect(subject).to receive(:sync_opt_ins)
        subject.sync_remote!
        expect(subject).to be_ok
      end
    end
  end

  describe '#claim!' do
    context 'when not unclaimed' do
      before do
        subject.pending!
      end

      specify do
        expect(subject).to receive(:sync_password_update)
        expect { subject.claim! }.to raise_error AASM::InvalidTransition
        expect(subject).to be_pending
      end
    end

    context 'when unclaimed' do
      before do
        subject.unclaimed!
      end

      context 'and having pending wallet provisions' do
        before do
          create(:wallet, ore_id_account: subject)
          subject.wallets.last.wallet_provisions.create(token: create(:algo_sec_token))
        end

        specify do
          expect { subject.claim! }.to raise_error AASM::InvalidTransition
          expect(subject).to be_unclaimed
        end
      end

      context 'and having no pending wallet provisions' do
        before do
          create(:wallet, ore_id_account: subject)
          subject.wallets.last.wallet_provisions.create(token: create(:algo_sec_token), state: :provisioned)
        end

        specify do
          expect(subject).to receive(:sync_password_update)
          subject.claim!
          expect(subject).to be_ok
        end
      end

      context 'and having no wallet provisions' do
        specify do
          expect(subject).to receive(:sync_password_update)
          subject.claim!
          expect(subject).to be_ok
        end
      end
    end
  end

  describe '#unlink!' do
    specify do
      expect(subject).to receive(:destroy!)
      subject.unlink!
    end
  end

  describe '#service' do
    subject { create(:ore_id, skip_jobs: true).service }
    it { is_expected.to be_an(OreIdService) }
  end

  describe '#create_account' do
    specify do
      expect(subject.service).to receive(:create_remote)
      subject.create_account
    end
  end

  describe '#pull_wallets' do
    context 'when wallet is not initialized locally' do
      before do
        subject.account.wallets.delete_all
      end

      it 'creates the wallet' do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.pull_wallets }.to change(subject.account.wallets, :count).by(1)
        end

        wallet = Wallet.last
        expect(wallet.address).to eq '4ZZ7D5JPF2MGHSHMAVDUJIVFFILYBHHFQ2J3RQGOCDHYCM33FHXRTLI4GQ'
        expect(wallet._blockchain).to eq 'algorand_test'
        expect(wallet.source).to eq 'ore_id'
      end
    end

    context 'when wallet is initialized locally' do
      before do
        create(
          :wallet,
          name: 'Test Wallet',
          _blockchain: :algorand_test,
          source: :ore_id,
          account: subject.account,
          ore_id_account: subject,
          address: nil
        )
      end

      it 'sets correct wallet params' do
        expect(subject.state).to eq 'pending'

        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.pull_wallets }.not_to change(subject.account.wallets, :count)
        end

        wallet = Wallet.last
        expect(wallet.address).to eq '4ZZ7D5JPF2MGHSHMAVDUJIVFFILYBHHFQ2J3RQGOCDHYCM33FHXRTLI4GQ'
        expect(wallet.source).to eq 'ore_id'
        expect(wallet.name).to eq 'Test Wallet'
      end
    end

    context 'when wallet is alredy pulled' do
      before do
        create(
          :wallet,
          name: 'Test Wallet',
          _blockchain: :algorand_test,
          source: :ore_id,
          account: subject.account,
          ore_id_account: subject,
          address: '4ZZ7D5JPF2MGHSHMAVDUJIVFFILYBHHFQ2J3RQGOCDHYCM33FHXRTLI4GQ'
        )
      end

      it 'does nothing' do
        expect(subject.state).to eq 'pending'

        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.pull_wallets }.not_to change(subject.account.wallets, :count)
        end
      end
    end
  end

  describe '#push_wallets' do
    let!(:wallet) do
      create(
        :wallet,
        name: 'Test Wallet',
        _blockchain: :algorand_test,
        source: :ore_id,
        account: subject.account,
        ore_id_account: subject,
        address: nil
      )
    end

    specify do
      expect_any_instance_of(OreIdService).to receive(:create_wallet)
      subject.push_wallets
    end
  end

  describe '#sync_opt_ins' do
    let!(:wallet) do
      create(
        :wallet,
        name: 'Test Wallet',
        _blockchain: :algorand_test,
        source: :ore_id,
        account: subject.account,
        ore_id_account: subject,
        address: nil
      )
    end

    specify do
      expect_any_instance_of(Wallet).to receive(:sync_opt_ins)
      subject.sync_opt_ins
    end
  end

  describe '#sync_password_update' do
    context 'when remote password has been updated' do
      before do
        allow_any_instance_of(OreIdService).to receive(:password_updated?).and_return(true)
      end

      specify do
        expect { subject.sync_password_update }.not_to raise_error(OreIdAccount::ProvisioningError)
      end
    end

    context 'when remote password has not been updated' do
      before do
        allow_any_instance_of(OreIdService).to receive(:password_updated?).and_return(false)
      end

      specify do
        expect { subject.sync_password_update }.to raise_error(OreIdAccount::ProvisioningError)
      end
    end
  end
end
