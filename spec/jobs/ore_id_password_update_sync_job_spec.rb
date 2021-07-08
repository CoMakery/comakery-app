require 'rails_helper'

RSpec.describe OreIdPasswordUpdateSyncJob, type: :job do
  subject(:perform) { described_class.perform_now(ore_id.id) }

  let(:now) { Time.zone.local(2021, 6, 1, 15) }
  let(:self_reschedule_job) { double('OreIdPasswordUpdateSyncJob', perform_later: nil) }
  let(:ore_id) { FactoryBot.create(:ore_id_account, state: 'pending_manual') }

  before do
    allow(described_class).to receive(:set).with(any_args).and_return(self_reschedule_job)
    allow_any_instance_of(OreIdAccount).to receive(:claim!)
    allow(Sentry).to receive(:capture_exception)
    Timecop.freeze(now)
  end

  shared_examples 'fails and reschedules itself with the delay' do |expected_delay|
    it do
      perform

      expect(described_class).to have_received(:set).with(wait: expected_delay).once
      expect(described_class).to have_received(:set).once
      expect(self_reschedule_job).to have_received(:perform_later).once

      expect(ore_id.synchronisations.last).to be_failed
      expect(Sentry).to have_received(:capture_exception).with(StandardError)
    end
  end

  shared_examples 'skips and reschedules itself with the delay' do |expected_delay|
    it do
      perform

      expect(described_class).to have_received(:set).with(wait: expected_delay).once
      expect(described_class).to have_received(:set).once
      expect(self_reschedule_job).to have_received(:perform_later).once

      expect(ore_id.synchronisations).to be_empty
      expect(Sentry).not_to have_received(:capture_exception).with(StandardError)
    end
  end

  context 'when sync is allowed' do
    before { allow_any_instance_of(ore_id.class).to receive(:sync_allowed?).and_return(true) }

    it 'calls create_remote and sets synchronisation status to ok' do
      expect_any_instance_of(ore_id.class).to receive(:claim!)

      perform

      expect(ore_id.synchronisations.last).to be_ok
    end

    context 'and service raises an error' do
      context 'when error is a standard error' do
        before { allow_any_instance_of(OreIdAccount).to receive(:claim!).and_raise(StandardError) }

        context 'when next sync allowed time is in the future' do
          before do
            allow_any_instance_of(ore_id.class)
              .to receive(:next_sync_allowed_after).and_return(1.hour.since(now))
          end

          it_behaves_like 'fails and reschedules itself with the delay', 1.hour
        end

        context 'when next sync allowed time is in the past' do
          before do
            allow_any_instance_of(ore_id.class)
              .to receive(:next_sync_allowed_after).and_return(1.hour.before(now))
          end

          it_behaves_like 'fails and reschedules itself with the delay', 0
        end
      end

      context 'when error is a OreIdAccount::ProvisioningError' do
        before do
          allow_any_instance_of(OreIdAccount)
            .to receive(:claim!).and_raise(OreIdAccount::ProvisioningError)
        end

        context 'when next sync allowed time is in the future' do
          before do
            allow_any_instance_of(ore_id.class)
              .to receive(:next_sync_allowed_after).and_return(1.hour.since(now))
          end

          it 'should fail and reschedule itself with the delay' do
            perform

            expect(described_class).to have_received(:set).with(wait: 1.hour).once
            expect(described_class).to have_received(:set).once
            expect(self_reschedule_job).to have_received(:perform_later).once

            expect(ore_id.synchronisations.last).to be_failed
            expect(Sentry).not_to have_received(:capture_exception)
          end
        end

        context 'when next sync allowed time is in the past' do
          before do
            allow_any_instance_of(ore_id.class)
              .to receive(:next_sync_allowed_after).and_return(1.hour.before(now))
          end

          it 'should fail and reschedule itself with the delay' do
            perform

            expect(described_class).to have_received(:set).with(wait: 0).once
            expect(described_class).to have_received(:set).once
            expect(self_reschedule_job).to have_received(:perform_later).once

            expect(ore_id.synchronisations.last).to be_failed
            expect(Sentry)
              .not_to have_received(:capture_exception)
              .with(instance_of(OreIdAccount::ProvisioningError))
          end
        end
      end
    end
  end

  context 'when sync is not allowed' do
    before { allow_any_instance_of(ore_id.class).to receive(:sync_allowed?).and_return(false) }

    context 'when next sync allowed time is in the future' do
      before do
        allow_any_instance_of(ore_id.class)
          .to receive(:next_sync_allowed_after).and_return(1.hour.since(now))
      end

      it_behaves_like 'skips and reschedules itself with the delay', 1.hour
    end

    context 'when next sync allowed time is in the past' do
      before do
        allow_any_instance_of(ore_id.class)
          .to receive(:next_sync_allowed_after).and_return(1.hour.before(now))
      end

      it_behaves_like 'skips and reschedules itself with the delay', 0
    end
  end
end
