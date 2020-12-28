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

  describe '#to_object' do
    subject { algorand_tx.to_object }

    specify { expect(subject['type']).to eq('pay') }
    specify { expect(subject['from']).to eq(algorand_tx.blockchain_transaction.source) }
    specify { expect(subject['to']).to eq(algorand_tx.blockchain_transaction.destination) }
    specify { expect(subject['amount']).to eq(algorand_tx.blockchain_transaction.amount) }
  end

  describe '#valid?' do
    let(:amount) { 9000000 }
    let(:source) { build(:algorand_address_1) }
    let(:destination) { build(:algorand_address_2) }
    let(:current_round) { 10661139 }
    let(:blockchain_transaction) do
      build(
        :blockchain_transaction,
        token: create(:algorand_token),
        amount: amount,
        source: source,
        destination: destination,
        current_block: current_round
      )
    end

    subject { algorand_tx.valid? }

    context 'for incorrect source' do
      let(:source) { build(:algorand_address_2) }

      it { is_expected.to be false }
    end

    context 'for incorrect destination' do
      let(:destination) { build(:algorand_address_1) }

      it { is_expected.to be false }
    end

    context 'for incorrect amount' do
      let(:amount) { 8999999 }

      it { is_expected.to be false }
    end

    context 'for incorrect current round' do
      let(:current_round) { 10661140 }

      it { is_expected.to be false }
    end

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end
