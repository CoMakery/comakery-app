require 'rails_helper'

describe BlockchainTransaction, vcr: true do
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
      %i[amount source destination network contract_address current_block].each do |attr|
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

    it 'sets current block' do
      expect(blockchain_transaction.current_block).to eq(7890718)
    end

    context 'with comakery token and nonce provided' do
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

    context 'without comakery security token' do
      let!(:blockchain_transaction) do
        build(
          :blockchain_transaction,
          token: create(
            :token,
            coin_type: :eth,
            ethereum_network: :ropsten
          )
        )
      end

      it 'doesnt generate transaction data' do
        expect(blockchain_transaction_burn.tx_hash).to be_nil
        expect(blockchain_transaction_burn.tx_raw).to be_nil
      end
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
    let!(:succeed_blockchain_transaction) do
      create(
        :blockchain_transaction,
        tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d',
        source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
        destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
        amount: 100,
        current_block: 0
      )
    end

    let!(:failed_blockchain_transaction) { create(:blockchain_transaction, nonce: 1, tx_hash: '0x94f00ce58c31913178e1aeab790967f7f62545126de118a064249a883c4159d4', current_block: 0) }
    let!(:unconfirmed_blockchain_transaction) { create(:blockchain_transaction, nonce: 1, tx_hash: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', current_block: 0) }

    it 'udpates status to succeed for successfull transaction' do
      succeed_blockchain_transaction.sync

      expect(succeed_blockchain_transaction.reload.status).to eq('succeed')
    end

    it 'udpates status to failed for failed transaction' do
      failed_blockchain_transaction.sync

      expect(failed_blockchain_transaction.reload.status).to eq('failed')
      expect(failed_blockchain_transaction.reload.status_message).to eq('Failed on chain')
    end

    it 'returns false for unconfirmed transaction' do
      expect(unconfirmed_blockchain_transaction.sync).to be_falsey
    end

    it 'calls update_number_of_syncs' do
      succeed_blockchain_transaction.sync

      expect(succeed_blockchain_transaction.reload.number_of_syncs).to eq(1)
    end
  end

  describe 'on_chain', :vcr do
    context 'with eth transfer' do
      it 'returns Comakery::EthTx' do
        blockchain_transaction = build(
          :blockchain_transaction,
          token: create(
            :token,
            coin_type: :eth,
            ethereum_network: :ropsten
          )
        )

        expect(blockchain_transaction.on_chain).to be_an(Comakery::EthTx)
      end
    end

    context 'with erc20 transfer' do
      it 'returns Comakery::Erc20Transfer' do
        blockchain_transaction = build(:blockchain_transaction)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Erc20Transfer)
      end
    end

    context 'with erc20 mint' do
      it 'returns Comakery::Erc20Mint' do
        blockchain_transaction = build(:blockchain_transaction)
        blockchain_transaction.award.update(source: :mint)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Erc20Mint)
      end
    end

    context 'with erc20 burn' do
      it 'returns Comakery::Erc20Burn' do
        blockchain_transaction = build(:blockchain_transaction)
        blockchain_transaction.award.update(source: :burn)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Erc20Burn)
      end
    end
  end

  describe 'confirmed_on_chain?', :vcr do
    context 'for unconfirmed transaction' do
      let!(:blockchain_transaction) { build(:blockchain_transaction, tx_hash: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff') }

      it 'returns false' do
        expect(blockchain_transaction.confirmed_on_chain?).to be_falsey
      end
    end

    context 'for confirmed transaction' do
      let!(:blockchain_transaction) { build(:blockchain_transaction, tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d') }

      it 'returns true' do
        expect(blockchain_transaction.confirmed_on_chain?).to be_truthy
      end
    end
  end

  describe 'valid_on_chain?', :vcr do
    context 'with eth token' do
      let!(:token) do
        create(
          :token,
          coin_type: :eth,
          ethereum_network: :ropsten
        )
      end

      let!(:valid_eth_tx) do
        build(
          :blockchain_transaction,
          token: token,
          tx_hash: '0xd6aecf2ea1af6f4e8a04537f222dee7e5813e7b1c85f425906343cb0d4eb82f8',
          destination: '0xbbc7e3ee37977ca508f63230471d1001d22bfdd5',
          source: '0x81b7e08f65bdf5648606c89998a9cc8164397647',
          amount: 1,
          current_block: 0
        )
      end

      let!(:invalid_eth_tx) do
        build(
          :blockchain_transaction,
          token: token,
          tx_hash: '0x1bcda0a705a6d79935b77c8f05ab852102b1bc6aa90a508ac0c23a35d182289f'
        )
      end

      it 'returns true for valid transaction' do
        expect(valid_eth_tx.valid_on_chain?).to be_truthy
      end

      it 'returns false for invalid transaction' do
        expect(invalid_eth_tx.valid_on_chain?).to be_falsey
      end
    end

    context 'with erc20 transfer' do
      let!(:valid_erc20_transfer) do
        build(
          :blockchain_transaction,
          tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d',
          destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
          source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
          amount: 100,
          current_block: 0
        )
      end

      let!(:invalid_erc20_transfer) do
        build(
          :blockchain_transaction,
          tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d'
        )
      end

      it 'returns true for valid transaction' do
        expect(valid_erc20_transfer.valid_on_chain?).to be_truthy
      end

      it 'returns false for invalid transaction' do
        expect(invalid_erc20_transfer.valid_on_chain?).to be_falsey
      end
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

  describe 'seconds_to_wait_in_created' do
    it 'gets value from ENV' do
      ENV['BLOCKCHAIN_TX__SECONDS_TO_WAIT_IN_CREATED'] = '1'
      expect(described_class.seconds_to_wait_in_created).to eq(1)
      ENV['BLOCKCHAIN_TX__SECONDS_TO_WAIT_IN_CREATED'] = nil
    end

    it 'has default value' do
      expect(described_class.seconds_to_wait_in_created).to eq(600)
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

  describe 'waiting_in_created?' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }

    it 'returns true if created_at less than seconds_to_wait_in_created ago' do
      blockchain_transaction.update(created_at: 1.year.from_now)
      blockchain_transaction.reload

      expect(blockchain_transaction.waiting_in_created?).to be_truthy
    end

    it 'returns false if created_at greater than seconds_to_wait_in_created ago' do
      blockchain_transaction.update(created_at: 1.year.ago)
      blockchain_transaction.reload

      expect(blockchain_transaction.waiting_in_created?).to be_falsey
    end

    it 'returns false if not in created state' do
      blockchain_transaction.update(status: :failed)
      blockchain_transaction.reload

      expect(blockchain_transaction.waiting_in_created?).to be_falsey
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

    it 'updates status to cancelled if max_syncs is reached' do
      blockchain_transaction.update(status: :pending, number_of_syncs: described_class.max_syncs - 1)
      blockchain_transaction.update_number_of_syncs
      blockchain_transaction.reload

      expect(blockchain_transaction.status).to eq('cancelled')
    end
  end
end
