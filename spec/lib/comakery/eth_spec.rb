require 'rails_helper'

describe Comakery::Eth do
  describe 'initialization' do
    it 'uses infura project key from ENV' do
      expect(build(:eth_client).client.uri.path).to eq("/v3/#{ENV.fetch('INFURA_PROJECT_ID', '')}")
    end

    it 'uses provided host' do
      expect(build(:eth_client, host: 'mainnet.infura.io').client.uri.host).to eq('mainnet.infura.io')
    end
  end

  describe 'client' do
    it 'returns Ethereum::HttpClient' do
      expect(build(:eth_client).client).to be_a(Ethereum::HttpClient)
    end
  end

  describe 'current_block', vcr: true do
    it 'returns current eth block from blockchain' do
      expect(build(:eth_client).current_block).to eq(8691686)
    end
  end
end
