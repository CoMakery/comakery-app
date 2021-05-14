require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::SecurityToken::Pause, vcr: true do
  let!(:erc20_pause) { build(:security_token_pause, blockchain_transaction: create(:blockchain_transaction_pause)) }

  describe '#method_name' do
    subject { erc20_pause.method_name }

    it { is_expected.to eq('pause') }
  end

  describe '#method_params' do
    subject { erc20_pause.method_params }

    it { is_expected.to be_empty }
  end
end
