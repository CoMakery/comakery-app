require 'rails_helper'

RSpec.describe Api::V1::AccountTokenRecordsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/tokens/1/account_token_records').to route_to('api/v1/account_token_records#index', token_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/tokens/1/account_token_records').to route_to('api/v1/account_token_records#create', token_id: '1', format: :json)
    end

    it 'routes to #destroy_all' do
      expect(delete: '/api/v1/tokens/1/account_token_records').to route_to('api/v1/account_token_records#destroy_all', token_id: '1', format: :json)
    end
  end
end
