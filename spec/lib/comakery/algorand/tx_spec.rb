require 'rails_helper'

describe Comakery::Algorand::Tx, vcr: true do
  let!(:algorand_tx) { build(:algorand_tx) }

  before do
    VCR.use_cassette("Algorand/transcation/#{algorand_tx.hash}") do
      algorand_tx.data
    end
  end

  describe '#algorand' do
    it 'returns Comakery::Algorand' do
      expect(algorand_tx.algorand).to be_a(Comakery::Algorand)
    end
  end

  describe '#data' do
    it 'returns all data' do
      expect(algorand_tx.data).to be_a(Hash)
    end
  end

  describe '#transaction_data' do
    it 'returns transaction data' do
      expect(algorand_tx.transaction_data).to be_a(Hash)
    end
  end

  describe '#confirmed_round' do
    it 'returns transaction confirmed round' do
      expect(algorand_tx.confirmed_round).to eq(10661140)
    end
  end

  describe '#confirmed?' do
    context 'for unconfirmed transaction' do
      let!(:algorand_tx) { build(:algorand_tx, hash: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA') }

      it 'returns false' do
        expect(algorand_tx.confirmed?).to be false
      end
    end

    context 'for confirmed transaction' do
      it 'returns true' do
        expect(algorand_tx.confirmed?).to be true
      end
    end
  end
end
