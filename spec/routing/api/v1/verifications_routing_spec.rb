require 'rails_helper'

RSpec.describe Api::V1::VerificationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/accounts/1/verifications').to route_to('api/v1/verifications#index', account_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/accounts/1/verifications').to route_to('api/v1/verifications#create', account_id: '1', format: :json)
    end
  end
end
