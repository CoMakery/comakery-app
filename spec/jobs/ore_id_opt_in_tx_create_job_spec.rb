require 'rails_helper'

RSpec.describe OreIdOptInTxCreateJob, type: :job do
  subject { create(:ore_id) }

  context 'when sync is allowed' do
    before { allow_any_instance_of(subject.class).to receive(:sync_allowed?).and_return(true) }

    it 'calls create_opt_in_tx and sets synchronisation status to ok' do
      expect_any_instance_of(subject.class).to receive(:create_opt_in_tx)
      described_class.perform_now(subject.id)
      expect(subject.synchronisations.last).to be_ok
    end

    context 'and service raises an error' do
      before { subject.class.any_instance.stub(:service) { raise } }

      it 'reschedules itself and sets synchronisation status to failed' do
        expect_any_instance_of(described_class).to receive(:reschedule)
        expect { described_class.perform_now(subject.id) }.to raise_error(RuntimeError)
        expect(subject.synchronisations.last).to be_failed
      end
    end
  end

  context 'when sync is not allowed' do
    before { allow_any_instance_of(subject.class).to receive(:sync_allowed?).and_return(false) }

    it 'reschedules itself' do
      expect_any_instance_of(described_class).to receive(:reschedule)
      described_class.perform_now(subject.id)
    end
  end
end
