require 'rails_helper'

describe BlockchainTransactionUpdate do
  describe 'associations' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }
    let!(:blockchain_transaction_update) { create(:blockchain_transaction_update, blockchain_transaction: blockchain_transaction) }

    it 'belongs to blockchain_transaction' do
      expect(blockchain_transaction_update.blockchain_transaction).to eq(blockchain_transaction)
    end
  end
end
