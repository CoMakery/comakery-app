require 'rails_helper'

describe Comakery::Algorand::Tx::App::OptIn do
  let!(:algorand_app_opt_in_tx) { build(:algorand_app_opt_in_tx) }
  let(:app_id) { algorand_app_opt_in_tx.app_id }

  before do
    VCR.use_cassette("Algorand/transcation/#{algorand_app_opt_in_tx.hash}") do
      algorand_app_opt_in_tx.data
    end
  end

  describe '#transaction_on_completion' do
    subject { algorand_app_opt_in_tx.transaction_on_completion }
    it { is_expected.to eq('optin') }
  end

  describe '#valid?' do
    subject { algorand_app_opt_in_tx.valid? }
    before { allow(algorand_app_opt_in_tx.blockchain_transaction).to receive(:current_block).and_return(algorand_app_opt_in_tx.confirmed_round - 1) }

    context 'for incorrect app_transaction_on_completion' do
      before { allow(algorand_app_opt_in_tx).to receive(:app_transaction_on_completion).and_return('op') }

      it { is_expected.to be false }
    end

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end
