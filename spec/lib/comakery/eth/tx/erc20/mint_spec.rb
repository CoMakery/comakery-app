require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::Mint, vcr: true do
  let!(:erc20_mint) { build(:erc20_mint) }

  describe '#method_name' do
    subject { erc20_mint.method_name }

    it { is_expected.to eq('mint') }
  end
end
