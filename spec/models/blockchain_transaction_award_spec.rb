require 'rails_helper'

describe BlockchainTransactionAward, vcr: true do
  it { is_expected.to have_many(:blockchain_transactables_awards).dependent(:nullify) }
  it { is_expected.to respond_to(:blockchain_transactables) }

  describe 'callbacks' do
    let(:blockchain_transaction) { create(:blockchain_transaction, nonce: 0) }

    it 'populates transaction data from award' do
      expect(blockchain_transaction.amounts).not_to be_empty
      expect(blockchain_transaction.destinations).not_to be_empty
      expect(blockchain_transaction.amount).to eq(blockchain_transaction.token.to_base_unit(blockchain_transaction.blockchain_transactable.amount))
    end

    context 'with lockup token' do
      let(:blockchain_transaction) { create(:blockchain_transaction_lockup, nonce: 0) }

      it 'populates lockup transaction data from award' do
        expect(blockchain_transaction.commencement_dates).to eq([blockchain_transaction.blockchain_transactable.commencement_date.to_i])
        expect(blockchain_transaction.lockup_schedule_ids).to eq([blockchain_transaction.blockchain_transactable.lockup_schedule_id])
      end
    end
  end

  describe '#amounts' do
    subject { create(:blockchain_transaction).amounts }

    it 'returns amounts as integers' do
      expect(subject.first).to be_an(Integer)
    end
  end

  describe '#commencement_dates' do
    subject { create(:blockchain_transaction_lockup).commencement_dates }

    it 'returns commencement_dates as integers' do
      expect(subject.first).to be_an(Integer)
    end
  end

  describe '#lockup_schedule_ids' do
    subject { create(:blockchain_transaction_lockup).lockup_schedule_ids }

    it 'returns lockup_schedule_ids as integers' do
      expect(subject.first).to be_an(Integer)
    end
  end

  describe 'update_status' do
    let!(:blockchain_transaction) { create(:blockchain_transaction) }

    before do
      blockchain_transaction.update(tx_hash: '0')
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

    context 'with lockup transfer' do
      specify do
        blockchain_transaction = build(:blockchain_transaction_lockup)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::ScheduledToken::FundReleaseSchedule)
      end
    end

    context 'with lockup transfer batch' do
      specify do
        blockchain_transaction = build(:blockchain_transaction_lockup_batch)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::ScheduledToken::BatchFundReleaseSchedule)
      end
    end

    context 'with erc20 transfer' do
      specify do
        blockchain_transaction = build(:blockchain_transaction)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::Transfer)
      end
    end

    context 'with erc20 transfer batch' do
      specify do
        blockchain_transaction = build(:blockchain_transaction_award_batch)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::BatchTransfer)
      end
    end

    context 'with erc20 mint' do
      specify do
        blockchain_transaction = build(:blockchain_transaction)

        blockchain_transaction.blockchain_transactable.update(
          transfer_type: blockchain_transaction.blockchain_transactable.project.transfer_types.find_by(name: 'mint')
        )
        blockchain_transaction.remove_instance_variable(:@on_chain)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::Mint)
      end
    end

    context 'with erc20 burn' do
      specify do
        blockchain_transaction = build(:blockchain_transaction)

        blockchain_transaction.blockchain_transactable.update(
          transfer_type: blockchain_transaction.blockchain_transactable.project.transfer_types.find_by(name: 'burn')
        )
        blockchain_transaction.remove_instance_variable(:@on_chain)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Eth::Tx::Erc20::Burn)
      end
    end

    context 'with DAG transfer' do
      specify do
        blockchain_transaction = build(:blockchain_transaction_dag)

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Dag::Tx)
      end
    end

    context 'with Algorand transfer' do
      specify do
        blockchain_transaction = build(:blockchain_transaction, token: create(:algorand_token), destination: build(:algorand_address_1))

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx)
      end
    end

    context 'with Algorand Standart Asset transfer' do
      specify do
        blockchain_transaction = build(:blockchain_transaction, token: create(:asa_token), destination: build(:algorand_address_1))

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::Asset)
      end
    end

    context 'with Algorand Security Token transfer' do
      specify do
        blockchain_transaction = build(:algorand_app_transfer_tx).blockchain_transaction

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::App::SecurityToken::Transfer)
      end
    end

    context 'with Algorand Security Token mint' do
      specify do
        blockchain_transaction = build(:algorand_app_mint_tx).blockchain_transaction

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::App::SecurityToken::Mint)
      end
    end

    context 'with Algorand Security Token burn' do
      specify do
        blockchain_transaction = build(:algorand_app_burn_tx).blockchain_transaction

        expect(blockchain_transaction.on_chain).to be_an(Comakery::Algorand::Tx::App::SecurityToken::Burn)
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

  describe '#broadcast_updates' do
    let(:blockchain_transaction) { create(:blockchain_transaction) }
    subject { blockchain_transaction.broadcast_updates }

    it 'broadcasts templates' do
      expect(blockchain_transaction).to receive(:broadcast_replace_later_to).exactly(4).times
      subject
    end

    it 'is triggered after update' do
      expect(blockchain_transaction).to receive(:broadcast_updates)
      blockchain_transaction.update(updated_at: Time.current)
    end
  end
end
