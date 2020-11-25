require 'rails_helper'

describe Comakery::Algorand::Tx::Asset, vcr: true do
  let(:asset_id) { '13076367' }
  let!(:algorand_asset_tx) { build(:algorand_asset_tx, asset_id: asset_id) }

  before do
    VCR.use_cassette("Algorand/transcation/#{algorand_asset_tx.hash}") do
      algorand_asset_tx.data
    end
  end

  describe '#algorand' do
    it 'returns Comakery::Algorand' do
      expect(algorand_asset_tx.algorand).to be_a(Comakery::Algorand)
    end
  end

  describe '#data' do
    it 'returns all data' do
      expect(algorand_asset_tx.data).to be_a(Hash)
    end
  end

  describe '#transaction_data' do
    it 'returns transaction data' do
      expect(algorand_asset_tx.transaction_data).to be_a(Hash)
    end
  end

  describe '#confirmed_round' do
    it 'returns transaction confirmed round' do
      expect(algorand_asset_tx.confirmed_round).to eq(10699047)
    end
  end

  describe '#confirmed?' do
    context 'for unconfirmed transaction' do
      let!(:algorand_asset_tx) { build(:algorand_asset_tx, hash: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA') }

      it 'returns false' do
        expect(algorand_asset_tx.confirmed?).to be false
      end
    end

    context 'for confirmed transaction' do
      it 'returns true' do
        expect(algorand_asset_tx.confirmed?).to be true
      end
    end
  end

  describe '#valid?' do
    let(:amount) { 400 }
    let(:source) { 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA' }
    let(:destination) { build(:algorand_address_2) }
    let(:current_round) { 10661139 }
    let(:blockchain_transaction) do
      build(
        :blockchain_transaction,
        token: create(:algorand_token),
        amount: amount,
        source: source,
        destination: destination,
        current_block: current_round,
        contract_address: asset_id
      )
    end
    subject { algorand_asset_tx.valid?(blockchain_transaction) }

    context 'for incorrect source' do
      let(:source) { build(:algorand_address_2) }

      it { is_expected.to be false }
    end

    context 'for incorrect destination' do
      let(:destination) { build(:algorand_address_1) }

      it { is_expected.to be false }
    end

    context 'for incorrect amount' do
      let(:amount) { 399 }

      it { is_expected.to be false }
    end

    context 'for incorrect asset_id' do
      let(:asset_id) { '00000000' }

      it { is_expected.to be false }
    end

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end
