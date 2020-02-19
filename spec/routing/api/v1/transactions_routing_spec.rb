require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/api/v1/projects/1/transactions').to route_to('api/v1/transactions#create', project_id: '1', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/projects/1/transactions/1').to route_to('api/v1/transactions#update', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/projects/1/transactions/1').to route_to('api/v1/transactions#update', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/projects/1/transactions/1').to route_to('api/v1/transactions#destroy', id: '1', project_id: '1', format: :json)
    end
  end
end
