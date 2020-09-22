require 'rails_helper'

RSpec.describe BlockchainJob::SyncJob, type: :job do
  let!(:comakery_token) { stub_blockchain_sync && create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
  let!(:blockchain_transaction) { create(:blockchain_transaction, status: :pending) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  after do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  it 'schedules sync jobs for Comakery tokens' do
    expect { described_class.perform_now }.to have_enqueued_job(BlockchainJob::ComakerySecurityTokenJob::TokenSyncJob).exactly(2)
  end

  it 'schedules sync jobs for pending Blockchain Transactions' do
    expect { described_class.perform_now }.to have_enqueued_job(BlockchainJob::BlockchainTransactionSyncJob).exactly(1)
  end
end
