require 'rails_helper'

RSpec.describe OreIdWalletOptInTxSyncJob, type: :job do
  subject { create(:wallet_provision, state: :opt_in_created) }

  context 'when sync is allowed' do
    before { allow_any_instance_of(subject.class).to receive(:sync_allowed?).and_return(true) }

    it 'calls sync_opt_in_tx and sets synchronisation status to ok' do
      expect_any_instance_of(subject.class).to receive(:sync_opt_in_tx)
      described_class.perform_now(subject)
      expect(subject.synchronisations.last).to be_ok
    end

    context 'and an error is raised' do
      before { subject.class.any_instance.stub(:wallet) { raise } }

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
