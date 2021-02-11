require 'rails_helper'

describe Comakery::Algorand::Tx::Asset, vcr: true do
  let!(:algorand_asset_tx) { build(:algorand_asset_tx) }
  let(:asset_id) { algorand_asset_tx.asset_id }

  before do
    VCR.use_cassette("Algorand/transcation/#{algorand_asset_tx.hash}") do
      algorand_asset_tx.data
    end
  end

  describe '#to_object' do
    subject { algorand_asset_tx.to_object }

    specify { expect(subject[:type]).to eq('axfer') }
    specify { expect(subject[:from]).to eq(algorand_asset_tx.blockchain_transaction.source) }
    specify { expect(subject[:to]).to eq(algorand_asset_tx.blockchain_transaction.destination) }
    specify { expect(subject[:amount]).to eq(algorand_asset_tx.blockchain_transaction.amount) }
    specify { expect(subject[:assetId]).to eq(algorand_asset_tx.asset_id) }
  end

  describe '#transaction_asset_id' do
    subject { algorand_asset_tx.transaction_asset_id }
    it { is_expected.to eq(asset_id) }
  end

  describe '#receiver_address' do
    subject { algorand_asset_tx.receiver_address }
    it { is_expected.to eq('E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE') }
  end

  describe 'amount' do
    subject { algorand_asset_tx.amount }
    it { is_expected.to eq(400) }
  end

  describe '#valid?' do
    subject { algorand_asset_tx.valid? }
    before { allow(algorand_asset_tx.blockchain_transaction).to receive(:current_block).and_return(algorand_asset_tx.confirmed_round - 1) }

    context 'for incorrect asset_id' do
      before { allow(algorand_asset_tx).to receive(:asset_id).and_return(0) }
      it { is_expected.to be false }
    end

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end
