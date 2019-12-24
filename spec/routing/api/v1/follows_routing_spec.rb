require 'rails_helper'

RSpec.describe Api::V1::FollowsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/accounts/1/follows').to route_to('api/v1/follows#index', account_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/accounts/1/follows').to route_to('api/v1/follows#create', account_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/accounts/1/follows/1').to route_to('api/v1/follows#destroy', account_id: '1', id: '1', format: :json)
    end
  end
end
