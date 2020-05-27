require 'rails_helper'

describe Comakery::Eth::Contract::Erc20 do
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
end
