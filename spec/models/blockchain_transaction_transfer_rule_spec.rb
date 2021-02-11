require 'rails_helper'

describe BlockchainTransactionTransferRule, vcr: true do
  describe 'update_status' do
    let!(:blockchain_transaction) { create(:blockchain_transaction_transfer_rule) }

    before do
      blockchain_transaction.update_status(:pending, 'test')
    end

    it 'marks transfer rule as synced if status succeed' do
      blockchain_transaction.update_status(:succeed)

      expect(blockchain_transaction.blockchain_transactable.status).to eq('synced')
    end
  end

  describe 'on_chain' do
    context 'with Comakery Security Token' do
      specify do
        blockchain_transaction = build(:blockchain_transaction_transfer_rule)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer)
      end
    end

    context 'with Algorand Security Token' do
      specify do
        blockchain_transaction = build(:algorand_app_set_transfer_rule_tx).blockchain_transaction

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::App::SecurityToken::SetTransferRule)
      end
    end
  end

  describe 'tx' do
    let!(:blockchain_transaction) { create(:blockchain_transaction_transfer_rule, nonce: 0) }
    let!(:contract) do
      build(
        :erc20_contract,
        contract_address: blockchain_transaction.contract_address,
        abi: blockchain_transaction.token.abi,
        network: blockchain_transaction.network,
        nonce: blockchain_transaction.nonce
      )
    end

    it 'generates blockchain transaction data' do
      tx = contract.setAllowGroupTransfer(
        blockchain_transaction.blockchain_transactable.sending_group.blockchain_id,
        blockchain_transaction.blockchain_transactable.receiving_group.blockchain_id,
        blockchain_transaction.blockchain_transactable.lockup_until.to_i
      )

      expect(blockchain_transaction.tx_hash).to eq(tx.hash)
      expect(blockchain_transaction.tx_raw).to eq(tx.hex)
    end
  end
end
