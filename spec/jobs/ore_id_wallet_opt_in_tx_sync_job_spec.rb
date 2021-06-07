require 'rails_helper'

RSpec.describe OreIdWalletOptInTxSyncJob, type: :job do
  subject(:perform) { described_class.perform_now(wallet_provision) }

  let(:now) { Time.zone.local(2021, 6, 1, 15) }
  let(:self_reschedule_job) { double('OreIdWalletOptInTxSyncJob', perform_later: nil) }
  let(:wallet_provision) { create(:wallet_provision, state: :opt_in_created) }

  before do
    allow(described_class).to receive(:set).with(any_args).and_return(self_reschedule_job)
    allow(wallet_provision).to receive(:sync_opt_in_tx)
    allow(Sentry).to receive(:capture_exception)
    Timecop.freeze(now)
  end

  after { Timecop.return }

  shared_examples 'fails and reschedules itself with the delay' do |expected_delay|
    it do
      perform

      expect(described_class).to have_received(:set).with(wait: expected_delay).once
      expect(described_class).to have_received(:set).once
      expect(self_reschedule_job).to have_received(:perform_later).once

      expect(wallet_provision.synchronisations.last).to be_failed
      expect(Sentry).to have_received(:capture_exception).with(RuntimeError)
    end
  end

  shared_examples 'skips and reschedules itself with the delay' do |expected_delay|
    it do
      perform

      expect(described_class).to have_received(:set).with(wait: expected_delay).once
      expect(described_class).to have_received(:set).once
      expect(self_reschedule_job).to have_received(:perform_later).once

      expect(wallet_provision.synchronisations).to be_empty
      expect(Sentry).not_to have_received(:capture_exception)
    end
  end

  context 'when sync is allowed' do
    before { allow(wallet_provision).to receive(:sync_allowed?).and_return(true) }

    it 'calls sync_opt_in_tx and sets synchronisation status to ok' do
      perform

      expect(wallet_provision).to have_received(:sync_opt_in_tx).once
      expect(wallet_provision.synchronisations.last).to be_ok
    end

    context 'and an error is raised' do
      before { allow(wallet_provision).to receive(:sync_opt_in_tx).and_raise }

      context 'when next sync allowed time is in the future' do
        before do
          allow(wallet_provision)
            .to receive(:next_sync_allowed_after).and_return(1.hour.since(now))
        end

        it_behaves_like 'fails and reschedules itself with the delay', 1.hour
      end

      context 'when next sync allowed time is in the past' do
        before do
          allow(wallet_provision)
            .to receive(:next_sync_allowed_after).and_return(1.hour.before(now))
        end

        it_behaves_like 'fails and reschedules itself with the delay', 0
      end
    end
  end

  context 'when sync is not allowed' do
    before { allow(wallet_provision).to receive(:sync_allowed?).and_return(false) }

    context 'when next sync allowed time is in the future' do
      before do
        allow(wallet_provision)
          .to receive(:next_sync_allowed_after).and_return(1.hour.since(now))
      end

      it_behaves_like 'skips and reschedules itself with the delay', 1.hour
    end

    context 'when next sync allowed time is in the past' do
      before do
        allow(wallet_provision)
          .to receive(:next_sync_allowed_after).and_return(1.hour.before(now))
      end

      it_behaves_like 'skips and reschedules itself with the delay', 0
    end
  end
end
