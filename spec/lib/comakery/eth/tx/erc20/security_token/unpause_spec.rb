require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::SecurityToken::Unpause, vcr: true do
  let!(:erc20_unpause) { build(:security_token_unpause) }

  describe '#method_name' do
    subject { erc20_unpause.method_name }

    it { is_expected.to eq('unpause') }
  end

  describe '#method_params' do
    subject { erc20_unpause.method_params }

    it { is_expected.to be_empty }
  end
end
