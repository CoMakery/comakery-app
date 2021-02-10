require 'rails_helper'
require 'models/concerns/synchronisable_spec'

RSpec.describe OreIdAccount, type: :model do
  it_behaves_like 'synchronisable'

  before { allow_any_instance_of(described_class).to receive(:sync_allowed?).and_return(true) }

  subject { create(:ore_id) }
  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_many(:wallets).dependent(:destroy) }
  it { is_expected.to validate_uniqueness_of(:account_name) }
  it { is_expected.to define_enum_for(:state).with_values({ pending: 0, pending_manual: 1, unclaimed: 2, ok: 3, unlinking: 4 }) }

  specify { expect(subject.service).to be_an(OreIdService) }

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

  context 'after_update' do
    subject { described_class.create(account: create(:account), id: 99999) }

    context 'when account_name has been updated' do
      it 'schedules a wallet sync' do
        expect(OreIdWalletsSyncJob).to receive(:perform_later).with(subject.id)
        subject.update(account_name: 'dummy')
      end
    end

    context 'when state updated to ok' do
      it 'schedules assets sync' do
        expect(OreIdOptInSyncJob).to receive(:perform_later).with(subject.id)
        subject.update(state: :ok)
      end
    end
  end

  describe '#sync_wallets' do
    context 'when wallet is not initialized locally' do
      before do
        subject.account.wallets.delete_all
      end

      it 'creates the wallet' do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.sync_wallets }.to change(subject.account.wallets, :count).by(1)
        end

        wallet = Wallet.last
        expect(wallet.address).to eq '4ZZ7D5JPF2MGHSHMAVDUJIVFFILYBHHFQ2J3RQGOCDHYCM33FHXRTLI4GQ'
        expect(wallet._blockchain).to eq 'algorand_test'
        expect(wallet.source).to eq 'ore_id'

        expect(subject.state).to eq 'ok'
      end
    end

    context 'when wallet is initialized locally' do
      before do
        create(:wallet, _blockchain: :algorand_test, source: :ore_id, account: subject.account, ore_id_account: subject, address: nil)
      end

      it 'sets correct wallet params' do
        expect(subject.state).to eq 'pending'

        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.sync_wallets }.not_to change(subject.account.wallets, :count)
        end

        wallet = Wallet.last
        expect(wallet.address).to eq '4ZZ7D5JPF2MGHSHMAVDUJIVFFILYBHHFQ2J3RQGOCDHYCM33FHXRTLI4GQ'
        expect(wallet._blockchain).to eq 'algorand_test'
        expect(wallet.source).to eq 'ore_id'

        expect(subject.state).to eq 'ok'
      end
    end

    context 'with provision flow' do
      before do
        wallet = create(:wallet, _blockchain: :algorand_test, source: :ore_id, account: subject.account, ore_id_account: subject, address: nil)
        create(:wallet_provision, wallet: wallet, token: build(:asa_token), state: :pending)
      end

      it 'ore_id_account#state do not change' do
        expect(subject.state).to eq 'pending'

        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.sync_wallets }.not_to change(subject.account.wallets, :count)
        end

        expect(subject.reload.state).to eq 'pending'
      end
    end
  end

  describe '#sync_password_update' do
    context 'when remote password has been updated' do
      before do
        allow_any_instance_of(OreIdService).to receive(:password_updated?).and_return(true)
      end

      specify do
        expect(subject).to receive(:ok!)
        subject.sync_password_update
      end
    end
  end

  describe '#sync_opt_ins', vcr: true do
    subject { create(:ore_id, skip_jobs: true) }
    let(:wallet) do
      Wallet.create!(
        account: subject.account,
        address: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
        _blockchain: 'algorand_test',
        source: 'ore_id',
        ore_id_account: subject,
        name: 'Algorand Test'
      )
    end
    let(:tokens) { [create(:asa_token), create(:algo_sec_token)] }

    specify 'TokenOptIn has been added' do
      wallet && subject.wallets.reload
      tokens

      expect(TokenOptIn.count).to be_zero
      subject.sync_opt_ins

      expect(TokenOptIn.count).to eq 2
      created_opt_in = TokenOptIn.last
      expect(created_opt_in.status).to eq 'opted_in'
    end

    specify 'when no wallets' do
      tokens

      expect(TokenOptIn.count).to be_zero
      subject.sync_opt_ins

      expect(TokenOptIn.count).to eq 0
    end

    specify 'when no supported token' do
      wallet && subject.wallets.reload

      expect(TokenOptIn.count).to be_zero
      subject.sync_opt_ins

      expect(TokenOptIn.count).to eq 0
    end
  end

  describe '#unlink' do
    specify do
      expect(subject).to receive(:unlinking!)
      expect(subject).to receive(:destroy!)
      subject.unlink
    end
  end
end
