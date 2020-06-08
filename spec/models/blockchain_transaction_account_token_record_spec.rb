require 'rails_helper'

describe BlockchainTransactionAccountTokenRecord, vcr: true do
  describe 'update_status' do
    let!(:blockchain_transaction) { create(:blockchain_transaction_account_token_record) }

    before do
      blockchain_transaction.update_status(:pending, 'test')
    end

    it 'marks transfer rule as synced if status succeed' do
      blockchain_transaction.update_status(:succeed)

      expect(blockchain_transaction.blockchain_transactable.status).to eq('synced')
    end
  end

  describe 'on_chain' do
    it 'returns Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions' do
      blockchain_transaction = build(:blockchain_transaction_account_token_record)

      expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions)
    end
  end

  describe 'tx' do
    let!(:blockchain_transaction) { create(:blockchain_transaction_account_token_record, nonce: 0) }
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
      tx = contract.setAddressPermissions(
        blockchain_transaction.blockchain_transactable.account.ethereum_wallet,
        blockchain_transaction.blockchain_transactable.reg_group.blockchain_id,
        blockchain_transaction.blockchain_transactable.lockup_until.to_i,
        blockchain_transaction.blockchain_transactable.max_balance,
        blockchain_transaction.blockchain_transactable.account_frozen
      )

      expect(blockchain_transaction.tx_hash).to eq(tx.hash)
      expect(blockchain_transaction.tx_raw).to eq(tx.hex)
    end
  end
end
