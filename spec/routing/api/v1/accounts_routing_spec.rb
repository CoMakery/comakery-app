require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/api/v1/accounts/1').to route_to('api/v1/accounts#show', id: '1', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/accounts/1').to route_to('api/v1/accounts#update', id: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/accounts/1').to route_to('api/v1/accounts#update', id: '1', format: :json)
    end
  end
end
