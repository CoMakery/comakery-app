require 'rails_helper'

describe BlockchainTransaction do
  describe 'associations' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }
    let!(:blockchain_transaction_update) { create(:blockchain_transaction_update, blockchain_transaction: blockchain_transaction) }

    it 'belongs to award' do
      expect(blockchain_transaction.award).to be_an(Award)
    end

    it 'has_one token' do
      expect(blockchain_transaction.token).to be_a(Token)
    end

    it 'has_many updates' do
      expect(blockchain_transaction.updates.last).to eq(blockchain_transaction_update)
    end
  end

  describe 'validations' do
    it 'makes attributes readonly' do
      %i[amount source destination tx_raw tx_hash nonce network contract_address].each do |attr|
        expect(described_class.readonly_attributes).to include(attr.to_s)
      end
    end
  end

  describe 'callbacks' do
    let!(:blockchain_transaction) { create(:blockchain_transaction, nonce: 0) }
    let!(:award_mint) do
      a = blockchain_transaction.award.dup
      a.update(source: :mint)
      a
    end
    let!(:award_burn) do
      a = blockchain_transaction.award.dup
      a.update(source: :burn)
      a
    end
    let!(:blockchain_transaction_mint) { create(:blockchain_transaction, nonce: 0, award: award_mint) }
    let!(:blockchain_transaction_burn) { create(:blockchain_transaction, nonce: 0, award: award_burn) }
    let!(:contract) do
      build(
        :erc20_contract,
        contract_address: blockchain_transaction.contract_address,
        abi: blockchain_transaction.token.abi,
        network: blockchain_transaction.network,
        nonce: blockchain_transaction.nonce
      )
    end

    it 'populates transaction data from award and token' do
      expect(blockchain_transaction.amount).to eq(blockchain_transaction.token.to_base_unit(blockchain_transaction.award.amount))
      expect(blockchain_transaction.destination).to eq(blockchain_transaction.award.recipient_address)
      expect(blockchain_transaction.network).to eq(blockchain_transaction.token.ethereum_network)
      expect(blockchain_transaction.contract_address).to eq(blockchain_transaction.token.ethereum_contract_address)
    end

    it 'generates blockchain transaction data' do
      tx = contract.transfer(
        blockchain_transaction.destination,
        blockchain_transaction.amount
      )

      expect(blockchain_transaction.tx_hash).to eq(tx.hash)
      expect(blockchain_transaction.tx_raw).to eq(tx.hex)
    end

    it 'generates blockchain transaction data for mint' do
      tx = contract.mint(
        blockchain_transaction_mint.destination,
        blockchain_transaction_mint.amount
      )

      expect(blockchain_transaction_mint.tx_hash).to eq(tx.hash)
      expect(blockchain_transaction_mint.tx_raw).to eq(tx.hex)
    end

    it 'generates blockchain transaction data for burn' do
      tx = contract.burn(
        blockchain_transaction_burn.destination,
        blockchain_transaction_burn.amount
      )

      expect(blockchain_transaction_burn.tx_hash).to eq(tx.hash)
      expect(blockchain_transaction_burn.tx_raw).to eq(tx.hex)
    end
  end

  describe 'update_status' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }

    before do
      blockchain_transaction.update_status(:pending, 'test')
    end

    it 'updates status and status message attributes' do
      expect(blockchain_transaction.status).to eq('pending')
      expect(blockchain_transaction.status_message).to eq('test')
    end

    it 'creates new blockchain_transaction_update' do
      expect(blockchain_transaction.updates.last.status).to eq('pending')
      expect(blockchain_transaction.updates.last.status_message).to eq('test')
    end

    it 'marks award as paid if status succeed' do
      blockchain_transaction.update_status(:succeed)

      expect(blockchain_transaction.award.status).to eq('paid')
    end
  end

  describe 'sync', :vcr do
    let!(:succeed_blockchain_transaction) { create(:blockchain_transaction, nonce: 1, tx_hash: '0x2d5ca80d84f67b5f60322a68d2b6ceff49030961dde74b6465573bcb6f1a2abd') }
    let!(:failed_blockchain_transaction) { create(:blockchain_transaction, nonce: 1, tx_hash: '0x94f00ce58c31913178e1aeab790967f7f62545126de118a064249a883c4159d4') }
    let!(:unconfirmed_blockchain_transaction) { create(:blockchain_transaction, nonce: 1, tx_hash: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff') }

    it 'udpates status to succeed for successfull transaction' do
      succeed_blockchain_transaction.sync

      expect(succeed_blockchain_transaction.reload.status).to eq('succeed')
    end

    it 'udpates status to failed for failed transaction' do
      failed_blockchain_transaction.sync

      expect(failed_blockchain_transaction.reload.status).to eq('failed')
    end

    it 'returns false for unconfirmed transaction' do
      expect(unconfirmed_blockchain_transaction.sync).to be_falsey
    end
  end
end
