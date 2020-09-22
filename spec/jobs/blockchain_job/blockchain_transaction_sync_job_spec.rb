require 'rails_helper'

RSpec.describe BlockchainJob::BlockchainTransactionSyncJob, type: :job, vcr: true do
  let!(:created_blockchain_transaction) { create(:blockchain_transaction) }
  let!(:succeed_blockchain_transaction) do
    create(
      :blockchain_transaction,
      tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d',
      source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
      destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
      amount: 100,
      current_block: 1,
      status: :pending
    )
  end
  let!(:unconfirmed_blockchain_transaction) { create(:blockchain_transaction, status: :pending, nonce: 1, tx_hash: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff') }
  let!(:waiting_blockchain_transaction) { create(:blockchain_transaction, status: :pending) }

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
    expect { described_class.perform_now(unconfirmed_blockchain_transaction) }.to have_enqueued_job(BlockchainJob::BlockchainTransactionSyncJob)
  end

  it 'reschedules itself on a record waiting sync' do
    waiting_blockchain_transaction.update(synced_at: 1.year.from_now)
    ActiveJob::Base.queue_adapter = :test
    expect { described_class.perform_now(waiting_blockchain_transaction) }.to have_enqueued_job(BlockchainJob::BlockchainTransactionSyncJob)
  end
end
