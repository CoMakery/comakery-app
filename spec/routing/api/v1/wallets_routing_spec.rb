require 'rails_helper'

RSpec.describe Api::V1::WalletsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/accounts/1/wallets').to route_to('api/v1/wallets#index', account_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/accounts/1/wallets').to route_to('api/v1/wallets#create', account_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/accounts/1/wallets/1').to route_to('api/v1/wallets#destroy', account_id: '1', id: '1', format: :json)
    end
  end
end
