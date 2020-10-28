require 'rails_helper'

RSpec.describe OreIdWalletsSyncJob, type: :job do
  subject { create(:ore_id) }

  specify do
    expect_any_instance_of(subject.class).to receive(:sync_wallets)
    described_class.perform_now(subject.id)
  end

  context 'on OreIdService::RemoteInvalidError' do
    before do
      subject.update(account_name: nil)
      ActiveJob::Base.queue_adapter = :test
    end

    after do
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    end

    specify do
      expect { described_class.perform_now(subject.id) }.to have_enqueued_job(described_class).with(subject.id).exactly(1)
    end
  end
end
