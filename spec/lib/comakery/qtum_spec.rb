require 'rails_helper'

describe Comakery::Qtum do
  describe 'fetch_symbol_and_decimals' do
    it 'returns correct symbol and decimals' do
      qtum = described_class.new 'qtum_testnet'

      stub_qtum_fetch
      symbol, decimals = qtum.fetch_symbol_and_decimals '2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc'

      expect(symbol).to eq 'BIG'
      expect(decimals).to eq 0
    end
  end
end
