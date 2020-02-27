require 'rails_helper'

describe Comakery::Erc20 do
  describe 'initialization' do
    it 'uses infura project key from ENV' do
      expect(build(:erc20_contract).client.uri.path).to eq("/v3/#{ENV.fetch('INFURA_PROJECT_ID', '')}")
    end

    it 'uses provided network' do
      expect(build(:erc20_contract, network: :main).client.uri.host).to eq('mainnet.infura.io')
      expect(build(:erc20_contract, network: :ropsten).client.uri.host).to eq('ropsten.infura.io')
    end
  end

  describe 'contract calls' do
    let!(:contract) { build(:erc20_contract, nonce: 1) }

    it 'returns an Eth::Tx instance with correct payload, nonce and contract address' do
      tx = contract.transfer(
        build(:ethereum_address_1),
        Ethereum::Formatter.new.to_wei(1)
      )

      expect(tx.data).to eq('0xa9059cbb00000000000000000000000042d00fc2efdace4859187de4865df9baa320d5db0000000000000000000000000000000000000000000000000de0b6b3a7640000')
      expect(tx.nonce).to eq(contract.nonce)
      expect(tx.to).to eq(RLP::Utils.decode_hex(contract.contract.address[2..-1]))
    end

    it 'raises an exception for a function not present in ABI' do
      expect do
        contract.transfer_nothing
      end.to raise_error(NoMethodError)
    end
  end

  describe 'tx_status', :vcr do
    let!(:network) { :ropsten }
    let!(:unknown_tx) { '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' }
    let!(:successfull_tx) { '0x2d5ca80d84f67b5f60322a68d2b6ceff49030961dde74b6465573bcb6f1a2abd' }
    let!(:unsuccessfull_tx) { '0x94f00ce58c31913178e1aeab790967f7f62545126de118a064249a883c4159d4' }
    let!(:contract) { build(:erc20_contract, nonce: 1, network: network) }

    it 'returns nil if transaction is not present on blockchain' do
      expect(contract.tx_status(unknown_tx)).to be_nil
    end

    it 'returns correct status for successfull transaction' do
      expect(contract.tx_status(successfull_tx)).to eq(1)
    end

    it 'returns correct status for unsuccessfull transaction' do
      expect(contract.tx_status(unsuccessfull_tx)).to eq(0)
    end
  end
end
