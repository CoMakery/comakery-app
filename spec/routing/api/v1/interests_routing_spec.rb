require 'rails_helper'

RSpec.describe Api::V1::InterestsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/accounts/1/interests').to route_to('api/v1/interests#index', account_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/accounts/1/interests').to route_to('api/v1/interests#create', account_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/accounts/1/interests/1').to route_to('api/v1/interests#destroy', account_id: '1', id: '1', format: :json)
    end
  end
end
