require 'rails_helper'

describe Api::AccountsController do
  let(:public_address) { '0x6095d3729eac2f4769f92a1fe3e23f252b223e0e' }
  # signature with 'Comakery, I am signing my nonce: 18822'
  let(:signature) { '0x1052ebba4e1efeace65423ee33f3d10c045eb4084d45f96a1435f7c6c1e9f5c93600cd6c77796183c02c3bc620c28aa5cf6ee31e05d2e858dc8bc7ed3a59bc0b1b' }

  describe '#find_by_public_address' do
    before { post :create, params: { public_address: public_address, network_id: 1 }, format: :json }

    it 'without \'public_address\' param' do
      get :find_by_public_address
      expect(response.content_type).to eq 'application/json'
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
      expect(response.content_type).to eq 'application/json'
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
      account.update(nonce: '18822')
      post :auth, params: { public_address: public_address, signature: signature }, format: :json
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:success]).to be true

      # use this signature again
      post :auth, params: { public_address: public_address, signature: signature }, format: :json
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:success]).to be false
    end

    it 'with invalid \'public_address\' param' do
      account = Account.last
      account.update(nonce: '18822')
      post :auth, params: { public_address: 'invalid', signature: signature }, format: :json
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:success]).to be false
    end
  end
end
