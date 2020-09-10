require 'rails_helper'

RSpec.describe Blockchain::SyncJob, type: :job do
  let!(:comakery_token) { stub_blockchain_sync && create(:token, _token_type: :comakery, _blockchain: 'ethereum', contract_address: '0x0000000000000000000000000000000000000000') }
  let!(:blockchain_transaction) { create(:blockchain_transaction, status: :pending) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  after do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  it 'schedules sync jobs for Comakery tokens' do
    expect { described_class.perform_now }.to have_enqueued_job(Blockchain::ComakerySecurityToken::TokenSyncJob).exactly(2)
  end

  it 'schedules sync jobs for pending Blockchain Transactions' do
    expect { described_class.perform_now }.to have_enqueued_job(Blockchain::BlockchainTransactionSyncJob).exactly(1)
  end
end
