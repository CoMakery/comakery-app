require 'rails_helper'

describe TokenDecorator do
  let(:token) { (create :token).decorate }

  describe 'with ethereum contract' do
    let(:token) do
      build(:token,
            ethereum_contract_address: '0xa234567890b234567890a234567890b234567890').decorate
    end

    specify do
      expect(token.ethereum_contract_explorer_url)
        .to include("#{Rails.application.config.ethereum_explorer_site}/token/#{token.ethereum_contract_address}")
    end
  end

  describe 'with contract_address' do
    let(:token) do
      build(:token,
            coin_type: 'qrc20', blockchain_network: 'qtum_testnet',
            contract_address: 'a234567890b234567890a234567890b234567890').decorate
    end

    specify do
      expect(token.ethereum_contract_explorer_url)
        .to include(UtilitiesService.get_contract_url(token.blockchain_network, token.contract_address))
    end
  end

  describe '#currency_denomination' do
    specify do
      token.update denomination: 'USD'
      expect(token.currency_denomination).to eq('$')
    end

    specify do
      token.update denomination: 'BTC'
      expect(token.currency_denomination).to eq('฿')
    end

    specify do
      token.update denomination: 'ETH'
      expect(token.currency_denomination).to eq('Ξ')
    end
  end

  describe 'eth_data' do
    let!(:token) { create(:token, coin_type: :comakery) }

    it 'returns data for ethereum_controller.js' do
      data = token.decorate.eth_data

      expect(data['ethereum-payment-type']).to eq(token.coin_type)
      expect(data['ethereum-amount']).to eq(0)
      expect(data['ethereum-decimal-places']).to eq(token.decimal_places&.to_i)
      expect(data['ethereum-contract-address']).to eq(token.contract_address)
      expect(data['ethereum-contract-abi']).to eq(token.abi&.to_json)
    end
  end

  describe 'logo_url' do
    let!(:token) { create :token }

    it 'returns image_url if present' do
      token.update(logo_image: dummy_image)
      expect(token.decorate.logo_url).to include('dummy_image')
    end

    it 'returns default image' do
      expect(token.reload.decorate.logo_url).to include('image.png')
    end
  end

  describe 'network' do
    let!(:token_eth) { create(:token, coin_type: :eth) }
    let!(:token_btc) { create(:token, coin_type: :btc) }

    it 'returns ethereum_network' do
      expect(token_eth.decorate.network).to eq(token_eth.ethereum_network)
    end

    it 'returns blockchain_network' do
      expect(token_btc.decorate.network).to eq(token_btc.blockchain_network)
    end
  end

  describe 'contract_address' do
    let!(:token_eth) { create(:token, coin_type: :eth) }
    let!(:token_btc) { create(:token, coin_type: :btc) }

    it 'returns ethereum_contract_address' do
      expect(token_eth.decorate.contract_address).to eq(token_eth.ethereum_contract_address)
    end

    it 'returns contract_address' do
      expect(token_btc.decorate.contract_address).to eq(token_btc.contract_address)
    end
  end
end
