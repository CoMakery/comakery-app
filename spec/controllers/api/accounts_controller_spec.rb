require 'rails_helper'

describe Api::AccountsController do
  let(:public_address) { '0x6095d3729eac2f4769f92a1fe3e23f252b223e0e' }

  describe '#find_by_public_address' do
    it 'without \'public_address\' param' do
      get :find_by_public_address
      expect(response.content_type).to eq 'application/json'
      parsed_response = JSON.parse response.body
      expect(parsed_response).to eq({})
    end

    it '#create' do
      expect { post :create, params: { public_address: public_address, network_id: 1 }, format: :json }.to change(Account, :count).by(1)

      post :create, params: { public_address: public_address, network_id: 1 }, format: :json
      expect(response.content_type).to eq 'application/json'
      parsed_response = JSON.parse response.body, symbolize_names: true
      expect(parsed_response[:public_address]).to eq(public_address)
    end
  end
end
