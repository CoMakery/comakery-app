require 'rails_helper'
require 'models/concerns/synchronisable_spec'

RSpec.describe WalletProvision, type: :model do
  it_behaves_like 'synchronisable'
  before { allow_any_instance_of(described_class).to receive(:sync_allowed?).and_return(true) }
  let(:provision_state) { :pending }

  subject { create(:wallet_provision, wallet_address: build(:algorand_address_1), state: provision_state) }

  it { is_expected.to belong_to(:wallet) }
  it { is_expected.to belong_to(:token) }
  it {
    is_expected.to define_enum_for(:state).with_values({
      pending: 0,
      initial_balance_confirmed: 1,
      opt_in_created: 2,
      provisioned: 3
    })
  }

  describe 'after_create' do
    subject { build(:wallet_provision, wallet_address: build(:algorand_address_1), state: :pending) }

    it 'schedules a balance sync' do
      expect(OreIdWalletBalanceSyncJob).to receive(:perform_later).with(subject)
      subject.save!
    end
  end

  describe 'after_update' do
    context 'when state has been updated' do
      context 'to :initial_balance_confirmed' do
        it 'schedules an opt in tx creation' do
          expect(OreIdWalletOptInTxCreateJob).to receive(:perform_later).with(subject)
          subject.update!(state: :initial_balance_confirmed)
        end
      end

      context 'to :opt_in_created' do
        it 'schedules an opt in tx sync' do
          expect(OreIdWalletOptInTxSyncJob).to receive(:perform_later).with(subject)
          subject.update!(state: :opt_in_created)
        end
      end
    end
  end

  describe '#sync_balance' do
    let(:provision_state) { :pending }

    before do
      allow(subject).to receive(:wallet).and_return(Wallet.new)
      allow_any_instance_of(Wallet).to receive(:coin_balance).and_return(Balance.new)
      allow_any_instance_of(Balance).to receive(:value).and_return(coin_balance_value)
    end

    context 'when coin balance is positive' do
      let(:coin_balance_value) { 1 }

      specify do
        subject.sync_balance

        expect(subject.state).to eq 'initial_balance_confirmed'
      end

      context 'with non-pending state' do
        let(:provision_state) { :initial_balance_confirmed }

        specify 'do nothing' do
          expect_any_instance_of(Wallet).not_to receive(:coin_balance)
          expect(subject.sync_balance).to be nil
        end
      end
    end

    context 'when coin balance is not positive' do
      let(:coin_balance_value) { 0 }

      specify do
        expect { subject.sync_balance }.to raise_error(WalletProvision::ProvisioningError)
      end
    end
  end

  describe '#create_opt_in_tx', vcr: true do
    let(:provision_state) { :initial_balance_confirmed }

    context 'when opt_in tx has been created' do
      it 'calls service to sign the transaction' do
        expect_any_instance_of(OreIdService).to receive(:create_tx)
        expect(subject).to receive(:opt_in_created!)
        subject.create_opt_in_tx

        expect(TokenOptIn.last.wallet).to eq(subject.wallet)
        expect(BlockchainTransactionOptIn.last.blockchain_transactable.wallet).to eq(subject.wallet)
      end
    end

    context 'when state is not initial_balance_confirmed' do
      let(:provision_state) { :opt_in_created }

      it 'do nothing' do
        expect(TokenOptIn).not_to receive(:find_or_create_by)
        expect(subject.create_opt_in_tx).to be nil
      end
    end
  end

  describe '#sync_opt_in_tx' do
    let(:provision_state) { :opt_in_created }

    context 'when opt_in tx has been confirmed on blockchain' do
      specify do
        expect(subject).to receive(:provisioned!)
        subject.sync_opt_in_tx
      end
    end

    context 'when state is not opt_in_created' do
      let(:provision_state) { :provisioned }

      specify 'do nothing' do
        expect_any_instance_of(Wallet).not_to receive(:token_opt_ins)
        expect(subject.sync_opt_in_tx).to be nil
      end
    end
  end

  describe 'provisioning step-by-step', vcr: true do
    specify do
      expect(OreIdWalletBalanceSyncJob).to receive(:perform_later)
      expect(subject.state).to eq 'pending'
      allow_any_instance_of(Wallet).to receive(:coin_balance).and_return(Balance.new)
      allow_any_instance_of(Balance).to receive(:value).and_return(1)

      expect(OreIdWalletOptInTxCreateJob).to receive(:perform_later)
      subject.sync_balance
      expect(subject.state).to eq 'initial_balance_confirmed'

      expect(OreIdWalletOptInTxSyncJob).to receive(:perform_later)
      expect_any_instance_of(OreIdService).to receive(:create_tx).and_return(true)
      subject.create_opt_in_tx
      expect(subject.state).to eq 'opt_in_created'

      expect_any_instance_of(Wallet).to receive(:token_opt_ins).and_return([])
      subject.sync_opt_in_tx
      expect(subject.state).to eq 'provisioned'
    end
  end
end
