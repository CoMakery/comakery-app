require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::Burn, vcr: true do
  let!(:erc20_burn) { build(:erc20_burn) }

  describe '#method_name' do
    subject { erc20_burn.method_name }

    it { is_expected.to eq('burn') }
  end
end
