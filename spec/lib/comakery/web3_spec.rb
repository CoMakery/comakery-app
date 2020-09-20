require 'rails_helper'

describe Comakery::Web3 do
  describe 'contract' do
    let!(:web3) { described_class.new 'mainnet.infura.io' }
    let!(:address) { '0x6c6ee5e31d828de241282b9606c8e98ea48526e2' }

    it 'returns contract' do
      expect(web3.contract(address)).to be_an_instance_of(Web3::Eth::Contract::ContractInstance)
    end
  end

  describe 'fetch_symbol_and_decimals' do
    let!(:web3) { described_class.new 'mainnet.infura.io' }
    let!(:web3_test) { described_class.new 'test.infura.io' }
    let!(:address) { '0x6c6ee5e31d828de241282b9606c8e98ea48526e2' }

    it 'returns correct symbol and decimals for main network' do
      stub_web3_fetch
      symbol, decimals = web3.fetch_symbol_and_decimals(address)
      expect(symbol).to eq 'HOT'
      expect(decimals).not_to eq nil
    end

    it 'returns correct symbol and decimals for test network' do
      stub_web3_fetch('test.infura.io')
      symbol, decimals = web3_test.fetch_symbol_and_decimals(address)
      expect(symbol).to eq 'HOT'
      expect(decimals).not_to eq nil
    end

    it 'returns nils in case of failure' do
      stub_web3_fetch_failure
      symbol, decimals = web3.fetch_symbol_and_decimals(address)
      expect(symbol).to eq nil
      expect(decimals).to eq nil
    end
  end
end
