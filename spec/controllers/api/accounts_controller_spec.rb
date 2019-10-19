require 'rails_helper'

describe Api::AccountsController do
  let(:public_address) { '0x6095d3729eac2f4769f92a1fe3e23f252b223e0e' }
  let(:nonce) { 18822 }

  describe '#find_by_public_address' do
    before { post :create, params: { public_address: public_address, network_id: 1 }, format: :json }

    it 'without \'public_address\' param' do
      get :find_by_public_address
      expect(response.media_type).to eq 'application/json'
      parsed_response = JSON.parse response.body
      expect(parsed_response).to eq({})
    end

    it 'with valid \'public_address\' param' do
      get :find_by_public_address, params: { public_address: public_address }
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:public_address]).to eq(public_address)
    end
  end

  describe '#create' do
    it 'success' do
      post :create, params: { public_address: public_address, network_id: 1 }, format: :json
      expect(response.media_type).to eq 'application/json'
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:public_address]).to eq(public_address)
      expect(parsed_response[:ethereum_wallet]).to eq(public_address)
    end

    it 'failure' do
      post :create, params: { public_address: public_address, network_id: 1 }, format: :json
      post :create, params: { public_address: public_address, network_id: 2 }, format: :json
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:failed]).to be true
    end

    it 'count of accounts changed' do
      expect { post :create, params: { public_address: public_address, network_id: 1 }, format: :json }.to change(Account, :count).by(1)
    end
  end

  describe '#auth' do
    before { post :create, params: { public_address: public_address, network_id: 1 }, format: :json }

    it 'with valid \'public_address\' param' do
      account = Account.last
      account.nonce = '18822'
      account.save(validate: false)
      post :auth, params: { public_address: public_address, nonce: nonce }, format: :json
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:success]).to be true

      # use this nonce again
      post :auth, params: { public_address: public_address, nonce: nonce }, format: :json
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:success]).to be false
    end

    it 'with invalid \'public_address\' param' do
      account = Account.last
      account.update(nonce: '18822')
      post :auth, params: { public_address: 'invalid', nonce: nonce }, format: :json
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:success]).to be false
    end
  end
end
