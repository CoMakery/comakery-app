require 'rails_helper'

describe UtilitiesService do
  let(:wallet) { '0xaBe4449277c893B3e881c29B17FC737ff527Fa47' }

  context '.get_wallet_url' do
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
  end
end
