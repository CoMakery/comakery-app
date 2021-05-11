require 'rails_helper'
require Rails.root.join('db/data_migrations/20210504044557_migrate_blockchain_transactions_association.rb')

describe MigrateBlockchainTransactionsAssociation do
  let(:blockchain_transaction) { create(:blockchain_transaction) }
  let(:blockchain_transactable) { blockchain_transaction.blockchain_transactable }

  before do
    blockchain_transaction.update!(
      blockchain_transactable_type: blockchain_transactable.class.to_s,
      blockchain_transactable_id: blockchain_transactable.id,
      transaction_batch: nil
    )
  end

  subject { described_class.new.up }

  it 'creates transaction batch including transactable' do
    expect(blockchain_transaction.transaction_batch).to be_nil
    subject

    blockchain_transaction.reload
    expect(blockchain_transaction.transaction_batch).to be_present
    expect(blockchain_transaction.blockchain_transactable).to eq(blockchain_transactable)
  end
end
