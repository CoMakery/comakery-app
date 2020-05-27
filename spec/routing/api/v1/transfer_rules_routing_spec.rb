require 'rails_helper'

RSpec.describe Api::V1::TransferRulesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/transfer_rules').to route_to('api/v1/transfer_rules#index')
    end

    it 'routes to #new' do
      expect(get: '/api/v1/transfer_rules/new').to route_to('api/v1/transfer_rules#new')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/transfer_rules/1').to route_to('api/v1/transfer_rules#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/api/v1/transfer_rules/1/edit').to route_to('api/v1/transfer_rules#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/transfer_rules').to route_to('api/v1/transfer_rules#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/transfer_rules/1').to route_to('api/v1/transfer_rules#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/transfer_rules/1').to route_to('api/v1/transfer_rules#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/transfer_rules/1').to route_to('api/v1/transfer_rules#destroy', id: '1')
    end
  end
end
