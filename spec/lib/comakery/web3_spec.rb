require 'rails_helper'

describe Comakery::Web3 do
  describe 'fetch_symbol_and_decimals' do
    it 'returns correct symbol and decimals' do
      web3 = described_class.new 'main'

      stub_web3_fetch
      symbol, decimals = web3.fetch_symbol_and_decimals '0x6c6ee5e31d828de241282b9606c8e98ea48526e2'

      expect(symbol).to eq 'HOT'
<<<<<<< HEAD
      expect(symbol).not_to eq nil
=======
      expect(decimals).not_to eq nil
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
    end
  end
end
