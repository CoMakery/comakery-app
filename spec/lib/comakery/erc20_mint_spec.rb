require 'rails_helper'

describe Comakery::Erc20Mint, vcr: true do
  describe 'valid_method_id?' do
    context 'for erc20 mint transaction' do
      let!(:erc20_mint) { build(:erc20_mint) }

      it 'returns true' do
        expect(erc20_mint.valid_method_id?).to be_truthy
      end
    end

    context 'for other erc20 transactions' do
      let!(:erc20_mint) { build(:erc20_mint, hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d') }

      it 'returns false' do
        expect(erc20_mint.valid_method_id?).to be_falsey
      end
    end
  end
end
