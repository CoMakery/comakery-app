require 'rails_helper'

describe Comakery::Eth::Tx::Erc20, vcr: true do
  describe 'lookup_method_arg' do
    let!(:erc20_transfer) { build(:erc20_transfer) }

    it 'returns n-th argument' do
      expect(erc20_transfer.lookup_method_arg(0)).to eq(762726034774768999117400353397232810765115688017)
      expect(erc20_transfer.lookup_method_arg(1)).to eq(100)
    end
  end
end
