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

    it 'calls update_number_of_syncs' do
      succeed_blockchain_transaction.sync

      expect(succeed_blockchain_transaction.reload.number_of_syncs).to eq(1)
    end
  end

  describe 'number_of_confirmations' do
    it 'gets value from ENV' do
      ENV['BLOCKCHAIN_TX__NUMBER_OF_CONFIRMATIONS'] = '1'
      expect(described_class.number_of_confirmations).to eq(1)
      ENV['BLOCKCHAIN_TX__NUMBER_OF_CONFIRMATIONS'] = nil
    end

    it 'has default value' do
      expect(described_class.number_of_confirmations).to eq(3)
    end
  end

  describe 'seconds_to_wait_between_syncs' do
    it 'gets value from ENV' do
      ENV['BLOCKCHAIN_TX__SECONDS_TO_WAIT_BETWEEN_SYNCS'] = '1'
      expect(described_class.seconds_to_wait_between_syncs).to eq(1)
      ENV['BLOCKCHAIN_TX__SECONDS_TO_WAIT_BETWEEN_SYNCS'] = nil
    end

    it 'has default value' do
      expect(described_class.seconds_to_wait_between_syncs).to eq(10)
    end
  end

  describe 'max_syncs' do
    it 'gets value from ENV' do
      ENV['BLOCKCHAIN_TX__MAX_SYNCS'] = '1'
      expect(described_class.max_syncs).to eq(1)
      ENV['BLOCKCHAIN_TX__MAX_SYNCS'] = nil
    end

    it 'has default value' do
      expect(described_class.max_syncs).to eq(60)
    end
  end

  describe 'reached_max_syncs?' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }

    it 'returns true if number_of_syncs is equal or greater than max_syncs' do
      blockchain_transaction.update(number_of_syncs: described_class.max_syncs)
      blockchain_transaction.reload

      expect(blockchain_transaction.reached_max_syncs?).to be_truthy
    end

    it 'returns false if number_of_syncs is less than max_syncs' do
      blockchain_transaction.update(number_of_syncs: described_class.max_syncs - 1)
      blockchain_transaction.reload

      expect(blockchain_transaction.reached_max_syncs?).to be_falsey
    end
  end

  describe 'waiting_till_next_sync_is_allowed?' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }

    it 'returns true if synced_at less than seconds_to_wait_between_syncs ago' do
      blockchain_transaction.update(synced_at: 1.year.from_now + described_class.seconds_to_wait_between_syncs)
      blockchain_transaction.reload

      expect(blockchain_transaction.waiting_till_next_sync_is_allowed?).to be_truthy
    end

    it 'returns false if synced_at greater than seconds_to_wait_between_syncs ago' do
      blockchain_transaction.update(synced_at: 1.year.ago - described_class.seconds_to_wait_between_syncs)
      blockchain_transaction.reload

      expect(blockchain_transaction.waiting_till_next_sync_is_allowed?).to be_falsey
    end
  end

  describe 'update_number_of_syncs' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }

    it 'increments number_of_syncs and updates synced_at' do
      blockchain_transaction.update_number_of_syncs
      blockchain_transaction.reload

      expect(blockchain_transaction.number_of_syncs).to eq(1)
      expect(blockchain_transaction.synced_at).not_to be_nil
    end

    it 'updates status to failed if max_syncs is reached' do
      blockchain_transaction.update(status: :pending, number_of_syncs: described_class.max_syncs - 1)
      blockchain_transaction.update_number_of_syncs
      blockchain_transaction.reload

      expect(blockchain_transaction.status).to eq('failed')
    end
  end
end
