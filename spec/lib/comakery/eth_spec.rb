require 'rails_helper'

describe Comakery::Eth do
  describe 'initialization' do
    it 'uses infura project key from ENV' do
      expect(build(:eth_client).client.uri.path).to eq("/v3/#{ENV.fetch('INFURA_PROJECT_ID', '')}")
    end

    it 'uses provided network' do
      expect(build(:eth_client, network: :main).client.uri.host).to eq('mainnet.infura.io')
      expect(build(:eth_client, network: :ropsten).client.uri.host).to eq('ropsten.infura.io')
    end
  end

  describe 'client' do
    it 'returns Ethereum::HttpClient' do
      expect(build(:eth_client).client).to be_a(Ethereum::HttpClient)
    end
  end

  describe 'current_block', vcr: true do
    it 'returns current eth block from blockchain' do
      expect(build(:eth_client).current_block).to eq(9768969)
    end
  end
end
