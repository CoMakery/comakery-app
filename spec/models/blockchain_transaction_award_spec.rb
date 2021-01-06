require 'rails_helper'

describe BlockchainTransactionAward, vcr: true do
  describe 'callbacks' do
    let!(:blockchain_transaction) { create(:blockchain_transaction, nonce: 0) }
    let!(:award_mint) do
      a = blockchain_transaction.blockchain_transactable.dup
      a.update(source: :mint)
      a
    end
    let!(:award_burn) do
      a = blockchain_transaction.blockchain_transactable.dup
      a.update(source: :burn)
      a
    end
    let!(:blockchain_transaction_mint) { create(:blockchain_transaction, nonce: 0, blockchain_transactable: award_mint) }
    let!(:blockchain_transaction_burn) { create(:blockchain_transaction, nonce: 0, blockchain_transactable: award_burn) }
    let!(:blockchain_transaction_rule) { create(:blockchain_transaction, nonce: 0, blockchain_transactable: award_burn) }
    let!(:blockchain_transaction_account) { create(:blockchain_transaction, nonce: 0, blockchain_transactable: award_burn) }
    let!(:contract) do
      build(
        :erc20_contract,
        contract_address: blockchain_transaction.contract_address,
        abi: blockchain_transaction.token.abi,
        network: blockchain_transaction.network,
        nonce: blockchain_transaction.nonce
      )
    end

    it 'populates transaction data from award' do
      expect(blockchain_transaction.amount).to eq(blockchain_transaction.token.to_base_unit(blockchain_transaction.blockchain_transactable.amount))
      expect(blockchain_transaction.destination).to eq(blockchain_transaction.blockchain_transactable.recipient_address)
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
            _token_type: :eth,
            _blockchain: :ethereum_ropsten
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

    it 'marks award as paid if status succeed' do
      blockchain_transaction.update_status(:succeed)

      expect(blockchain_transaction.blockchain_transactable.status).to eq('paid')
    end
  end

  describe 'on_chain' do
    context 'with eth transfer' do
      it 'returns Comakery::EthTx' do
        blockchain_transaction = build(
          :blockchain_transaction,
          token: create(
            :token,
            _token_type: :eth,
            _blockchain: :ethereum_ropsten
          )
        )

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx)
      end
    end

    context 'with erc20 transfer' do
      it 'returns Comakery::Erc20Transfer' do
        blockchain_transaction = build(:blockchain_transaction)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::Transfer)
      end
    end

    context 'with erc20 mint' do
      it 'returns Comakery::Erc20Mint' do
        blockchain_transaction = build(:blockchain_transaction)
        blockchain_transaction.blockchain_transactable.update(
          transfer_type: blockchain_transaction.blockchain_transactable.project.transfer_types.find_by(name: 'mint')
        )

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::Mint)
      end
    end

    context 'with erc20 burn' do
      it 'returns Comakery::Erc20Burn' do
        blockchain_transaction = build(:blockchain_transaction)
        blockchain_transaction.blockchain_transactable.update(
          transfer_type: blockchain_transaction.blockchain_transactable.project.transfer_types.find_by(name: 'burn')
        )

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::Burn)
      end
    end

    context 'with DAG transfer' do
      it 'returns Comakery::Dag::Tx' do
        blockchain_transaction = build(:blockchain_transaction_dag)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Dag::Tx)
      end
    end

    context 'with Algorand transfer' do
      it 'returns Comakery::Algorand::Tx' do
        blockchain_transaction = build(:blockchain_transaction, token: create(:algorand_token), destination: build(:algorand_address_1))

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx)
      end
    end
  end

  describe 'confirmed_on_chain?' do
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

  describe 'valid_on_chain?' do
    context 'with eth token' do
      let!(:token) do
        create(
          :token,
          _token_type: :eth,
          _blockchain: :ethereum_ropsten
        )
      end

      let!(:valid_eth_tx) do
        build(
          :blockchain_transaction,
          token: token,
          tx_hash: '0xd6aecf2ea1af6f4e8a04537f222dee7e5813e7b1c85f425906343cb0d4eb82f8',
          destination: '0xbbc7e3ee37977ca508f63230471d1001d22bfdd5',
          source: '0x81b7e08f65bdf5648606c89998a9cc8164397647',
          amount: 1000000000000000000,
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
end
