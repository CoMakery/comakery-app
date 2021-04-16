require 'rails_helper'

RSpec.describe OreIdPasswordUpdateSyncJob, type: :job do
  subject { create(:ore_id, skip_jobs: true, state: 'unclaimed') }

  context 'when sync is allowed' do
    before { allow_any_instance_of(subject.class).to receive(:sync_allowed?).and_return(true) }

    it 'calls claim and sets synchronisation status to ok' do
      expect_any_instance_of(subject.class).to receive(:claim!)
      described_class.perform_now(subject.id)
      expect(subject.synchronisations.last).to be_ok
    end

    context 'and service raises an unknown error' do
      before { subject.class.any_instance.stub(:service) { raise } }

      it 'reschedules itself and sets synchronisation status to failed' do
        expect_any_instance_of(described_class).to receive(:reschedule)
        expect(Sentry).to receive(:capture_exception).with(RuntimeError)
        described_class.perform_now(subject.id)
        expect(subject.synchronisations.last).to be_failed
      end
    end

    context 'and service raises the OreIdAccount::ProvisioningError error' do
      before { subject.class.any_instance.stub(:service) { raise OreIdAccount::ProvisioningError } }

      it 'reschedules itself and sets synchronisation status to failed' do
        expect_any_instance_of(described_class).to receive(:reschedule)
        expect { described_class.perform_now(subject.id) }.not_to raise_error
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
