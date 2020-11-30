require 'rails_helper'

describe BlockchainTransactionOptIn do
  describe 'update_status' do
    let(:blockchain_transaction) { create(:blockchain_transaction_opt_in) }

    before do
      blockchain_transaction.update_status(:pending, 'test')
    end

    it 'marks TokenOptIn status as opted_in if status succeed' do
      blockchain_transaction.update_status(:succeed)

      expect(blockchain_transaction.blockchain_transactable.status).to eq('opted_in')
    end
  end

  describe 'on_chain' do
    let(:blockchain_transaction) { build(:blockchain_transaction_opt_in) }

    it 'returns Comakery::Algorand::Tx::Asset' do
      expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::Asset)
    end
  end
end
