require 'rails_helper'

RSpec.describe BlockchainJob::BlockchainTransactionSyncJob, type: :job, vcr: true do
  it 'doesnt sync non-pending record' do
    created_blockchain_transaction = create(:blockchain_transaction)
    described_class.perform_now(created_blockchain_transaction)
    expect(created_blockchain_transaction.reload.status).to eq('created')
  end

  it 'syncs pending record' do
    succeed_blockchain_transaction = create(
      :blockchain_transaction,
      tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d',
      source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
      destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
      amount: 100,
      current_block: 1,
      status: :pending
    )
    described_class.perform_now(succeed_blockchain_transaction)
    expect(succeed_blockchain_transaction.reload.status).to eq('succeed')
  end

  it 'reschedules itself on failed sync' do
    unconfirmed_blockchain_transaction = create(:blockchain_transaction, status: :pending, nonce: 1, tx_hash: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')
    ActiveJob::Base.queue_adapter = :test
    expect { described_class.perform_now(unconfirmed_blockchain_transaction) }.to have_enqueued_job(BlockchainJob::BlockchainTransactionSyncJob)
  end

  it 'reschedules itself on a record waiting sync' do
    waiting_blockchain_transaction = create(:blockchain_transaction, status: :pending)
    waiting_blockchain_transaction.update(synced_at: 1.year.from_now)
    ActiveJob::Base.queue_adapter = :test
    expect { described_class.perform_now(waiting_blockchain_transaction) }.to have_enqueued_job(BlockchainJob::BlockchainTransactionSyncJob)
  end

  describe 'sync succeed algorand transaction' do
    let(:blockchain_transaction) do
      create(
        :blockchain_transaction,
        token: create(:algorand_token),
        tx_hash: 'MNGGXTRI4XE6LQJQ3AW3PBBGD5QQFRXMRSXZFUMHTKJKFEQ6TZ2A',
        amount: 9000000,
        source: build(:algorand_address_1),
        destination: build(:algorand_address_2),
        status: :pending,
        current_block: 10661139
      )
    end

    it 'update status of the transaction' do
      described_class.perform_now(blockchain_transaction)
      expect(blockchain_transaction.reload.status).to eq 'succeed'
    end
  end

  describe 'sync succeed algorand asset transaction' do
    let(:blockchain_transaction) do
      build(
        :blockchain_transaction,
        token: create(:asa_token),
        tx_hash: 'D2SAP75JSXW3D43ZBHNLTJGASBCJDJIFLLQ5TQCZWMC33JHHQDPQ',
        amount: 400,
        source: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
        destination: build(:algorand_address_2),
        contract_address: '13076367',
        status: :pending,
        current_block: 10661139
      )
    end

    it 'update status of the transaction' do
      described_class.perform_now(blockchain_transaction)
      expect(blockchain_transaction.reload.status).to eq 'succeed'
    end
  end
end
