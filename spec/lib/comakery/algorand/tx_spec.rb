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
      before { allow(algorand_tx).to receive(:current_round).and_return(algorand_tx.confirmed_round - 1) }

      it 'returns false' do
        expect(algorand_tx.confirmed?).to be false
      end
    end

    context 'for confirmed transaction' do
      before { allow(algorand_tx).to receive(:current_round).and_return(algorand_tx.confirmed_round + 1) }

      it 'returns true' do
        expect(algorand_tx.confirmed?).to be true
      end
    end
  end

  describe '#to_object' do
    subject { algorand_tx.to_object }

    specify { expect(subject[:type]).to eq('pay') }
    specify { expect(subject[:from]).to eq(algorand_tx.blockchain_transaction.source) }
    specify { expect(subject[:to]).to eq(algorand_tx.blockchain_transaction.destination) }
    specify { expect(subject[:amount]).to eq(algorand_tx.blockchain_transaction.amount) }
  end

  describe '#valid?' do
    subject { algorand_tx.valid? }
    before { allow(algorand_tx.blockchain_transaction).to receive(:current_block).and_return(algorand_tx.confirmed_round - 1) }

    context 'for incorrect source' do
      before { allow(algorand_tx.blockchain_transaction).to receive(:source).and_return('0') }

      it { is_expected.to be false }
    end

    context 'for incorrect destination' do
      before { allow(algorand_tx.blockchain_transaction).to receive(:destination).and_return('0') }

      it { is_expected.to be false }
    end

    context 'for incorrect amount' do
      before { allow(algorand_tx.blockchain_transaction).to receive(:amount).and_return(0) }

      it { is_expected.to be false }
    end

    context 'for incorrect current block' do
      before { allow(algorand_tx.blockchain_transaction).to receive(:current_block).and_return(algorand_tx.confirmed_round + 1) }

      it { is_expected.to be false }
    end

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end
