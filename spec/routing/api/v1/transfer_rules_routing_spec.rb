require 'rails_helper'

RSpec.describe Api::V1::TransferRulesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/projects/1/transfer_rules').to route_to('api/v1/transfer_rules#index', project_id: '1', format: :json)
    end

    it 'routes to #show' do
      expect(get: '/api/v1/projects/1/transfer_rules/1').to route_to('api/v1/transfer_rules#show', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/projects/1/transfer_rules').to route_to('api/v1/transfer_rules#create', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/projects/1/transfer_rules/1').to route_to('api/v1/transfer_rules#destroy', id: '1', project_id: '1', format: :json)
    end
  end
end
