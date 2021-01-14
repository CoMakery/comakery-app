require 'rails_helper'

RSpec.describe OreIdWalletOptInTxCreateJob, type: :job do
  let(:ore_id_account) { create(:ore_id, skip_jobs: true) }
  let(:wallet) { create(:wallet, ore_id_account: ore_id_account, account: ore_id_account.account, _blockchain: :algorand_test, source: :ore_id, address: build(:algorand_address_1)) }
  let(:wallet_provision) { create(:wallet_provision, wallet: wallet, token: build(:asa_token), state: :initial_balance_confirmed) }
  subject { wallet_provision }

  context 'when sync is allowed' do
    before { allow_any_instance_of(subject.class).to receive(:sync_allowed?).and_return(true) }

    it 'calls create_opt_in_tx and sets synchronisation status to ok' do
      expect_any_instance_of(subject.class).to receive(:create_opt_in_tx)
      described_class.perform_now(subject)
      expect(subject.synchronisations.last).to be_ok
    end

    context 'and service raises an error' do
      before do
        create(:asa_token)
        subject.class.any_instance.stub(:ore_id_account) { raise }
        allow_any_instance_of(Comakery::Algorand).to receive(:last_round).and_return(1000000)
      end

      it 'reschedules itself and sets synchronisation status to failed' do
        expect_any_instance_of(described_class).to receive(:reschedule)
        expect { described_class.perform_now(subject) }.to raise_error(RuntimeError)
        expect(subject.synchronisations.last).to be_failed
      end
    end
  end

  context 'when sync is not allowed' do
    before { allow_any_instance_of(subject.class).to receive(:sync_allowed?).and_return(false) }

    it 'reschedules itself' do
      expect_any_instance_of(described_class).to receive(:reschedule)
      described_class.perform_now(subject)
    end
  end
end
