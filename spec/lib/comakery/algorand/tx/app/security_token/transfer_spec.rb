require 'rails_helper'

describe Comakery::Algorand::Tx::App::SecurityToken::Transfer do
  let!(:tx) { build(:algorand_app_transfer_tx) }
  let(:app_id) { tx.app_id }

  before do
    VCR.use_cassette("Algorand/transcation/#{tx.hash}") do
      tx.data
    end
  end

  describe '#app_args' do
    subject { tx.app_args }
    it { is_expected.to eq(['transfer', 15]) }
  end

  describe '#app_accounts' do
    subject { tx.app_accounts }
    it { is_expected.to eq([tx.blockchain_transaction.destination]) }
  end

  describe '#valid?' do
    subject { tx.valid? }
    before { allow(tx.blockchain_transaction).to receive(:current_block).and_return(tx.confirmed_round - 1) }

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end
