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

  describe 'logo_url' do
    let!(:token) { create :token }

    it 'returns image_url if present' do
      token.update(logo_image: dummy_image)
      expect(token.decorate.logo_url).to include('dummy_image')
    end

    it 'returns default image' do
      expect(token.reload.decorate.logo_url).to include('image.png')
    end

    it 'includes url' do
      expect(token.decorate.logo_url).to start_with('https://')
    end

    it 'includes custom host' do
      expect(token.decorate.logo_url(host: 'host')).to start_with('https://host')
    end

    context 'when image is not present' do
      before do
        allow(token).to receive(:logo_image).and_return(nil)
      end

      it 'returns nil' do
        expect(token.decorate.logo_url).to be_nil
      end
    end
  end

  describe 'network' do
    let!(:token_btc) { create(:token, _token_type: :btc) }

    it 'returns _blockchain' do
      expect(token_btc.decorate.network).to eq(token_btc._blockchain)
    end
  end
end
