require 'rails_helper'

describe BlockchainTransactionOptIn do
  describe 'update_status' do
    let(:blockchain_transaction) { create(:blockchain_transaction_opt_in) }

    before do
      blockchain_transaction.update(tx_hash: '0')
      blockchain_transaction.update_status(:pending, 'test')
    end

    it 'marks TokenOptIn status as opted_in if status succeed' do
      blockchain_transaction.update_status(:succeed)

      expect(blockchain_transaction.blockchain_transactable.status).to eq('opted_in')
    end
  end

  describe 'on_chain' do
    context 'with Algorand Standart Asset' do
      specify do
        blockchain_transaction = build(:algorand_asset_opt_in_tx).blockchain_transaction

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::Asset::OptIn)
      end
    end

    context 'with Algorand Security Token' do
      specify do
        blockchain_transaction = build(:algorand_app_opt_in_tx).blockchain_transaction

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::App::OptIn)
      end
    end
  end
end
