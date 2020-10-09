require 'rails_helper'

describe TokenDecorator do
  let(:token) { (create :token).decorate }

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
    let!(:token) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }

    it 'returns data for ethereum_controller.js' do
      data = token.decorate.eth_data

      expect(data['ethereum-payment-type']).to eq(token._token_type)
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
    let!(:token_btc) { create(:token, _token_type: :btc) }

    it 'returns _blockchain' do
      expect(token_btc.decorate.network).to eq(token_btc._blockchain)
    end
  end
end
