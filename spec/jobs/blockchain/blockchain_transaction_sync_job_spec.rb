require 'rails_helper'

RSpec.describe Blockchain::BlockchainTransactionSyncJob, type: :job, vcr: true do
  let!(:created_blockchain_transaction) { create(:blockchain_transaction) }
  let!(:succeed_blockchain_transaction) { create(:blockchain_transaction, status: :pending, nonce: 1, tx_hash: '0x2d5ca80d84f67b5f60322a68d2b6ceff49030961dde74b6465573bcb6f1a2abd') }
  let!(:unconfirmed_blockchain_transaction) { create(:blockchain_transaction, status: :pending, nonce: 1, tx_hash: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff') }

  it 'doesnt sync non-pending record' do
    described_class.perform_now(created_blockchain_transaction)
    expect(created_blockchain_transaction.reload.status).to eq('created')
  end

  it 'syncs pending record' do
    described_class.perform_now(succeed_blockchain_transaction)
    expect(succeed_blockchain_transaction.reload.status).to eq('succeed')
  end

  it 'reschedules itself on failed sync' do
    ActiveJob::Base.queue_adapter = :test
    expect { described_class.perform_now(unconfirmed_blockchain_transaction) }.to have_enqueued_job(Blockchain::BlockchainTransactionSyncJob)
  end
end
