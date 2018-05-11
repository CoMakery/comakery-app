require 'rails_helper'

describe Api::AccountsController do
  describe '#find_by_public_address' do
    it 'without \'public_address\' param' do
      get :find_by_public_address
      expect(response.content_type).to eq 'application/json'
      parsed_response = JSON.parse response.body
      expect(parsed_response).to eq({})
    end
  end
end
