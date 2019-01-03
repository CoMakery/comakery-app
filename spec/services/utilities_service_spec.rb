require 'rails_helper'

describe UtilitiesService do
  let(:wallet) { '0xaBe4449277c893B3e881c29B17FC737ff527Fa47' }
  let(:tx) { 'f5d3c28df8c2e983360756f8072718ef67593491d4d0cc73289b1e72070c3edc' }
  let(:contract) { '6797155d96718b58ddde3ba02c5173b6ee4e8581' }

  context '.get_wallet_url' do
    it 'without network' do
      network = nil

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq 'javascript:void(0);'
    end

    it 'wallet on Mainnet' do
      network = 'main'

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq "https://etherscan.io/address/#{wallet}"
    end

    it 'wallet on Ropsten' do
      network = 'ropsten'

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq "https://ropsten.etherscan.io/address/#{wallet}"
    end

    it 'wallet on Kovan' do
      network = 'kovan'

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq "https://kovan.etherscan.io/address/#{wallet}"
    end

    it 'wallet on Rinkeby' do
      network = 'rinkeby'

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq "https://rinkeby.etherscan.io/address/#{wallet}"
    end

    it 'wallet on qtum mainnet' do
      network = 'qtum_mainnet'

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq "https://explorer.qtum.org/address/#{wallet}"
    end

    it 'wallet on qtum testnet' do
      network = 'qtum_testnet'

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq "https://testnet.qtum.org/address/#{wallet}"
    end

    it 'wallet on cardano mainnet' do
      network = 'cardano_mainnet'

      result = described_class.get_wallet_url(network, wallet)

      expect(result).to eq "https://cardanoexplorer.com/address/#{wallet}"
    end
  end

  context '.get_transaction_url' do
    it 'transaction on qtum mainnet' do
      network = 'qtum_mainnet'

      result = described_class.get_transaction_url(network, tx)

      expect(result).to eq "https://explorer.qtum.org/tx/#{tx}"
    end

    it 'transaction on qtum testnet' do
      network = 'qtum_testnet'

      result = described_class.get_transaction_url(network, tx)

      expect(result).to eq "https://testnet.qtum.org/tx/#{tx}"
    end

    it 'transaction on cardano mainnet' do
      network = 'cardano_mainnet'

      result = described_class.get_transaction_url(network, tx)

      expect(result).to eq "https://cardanoexplorer.com/tx/#{tx}"
    end
  end

  context '.get_contract_url' do
    it 'contract on qtum mainnet' do
      network = 'qtum_mainnet'

      result = described_class.get_contract_url(network, contract)

      expect(result).to eq "https://explorer.qtum.org/token/#{contract}"
    end

    it 'contract on qtum testnet' do
      network = 'qtum_testnet'

      result = described_class.get_contract_url(network, contract)

      expect(result).to eq "https://testnet.qtum.org/token/#{contract}"
    end
  end
end
