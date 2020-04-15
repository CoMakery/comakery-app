require 'rails_helper'

RSpec.describe Api::V1::BlockchainTransactionsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/api/v1/projects/1/blockchain_transactions').to route_to('api/v1/blockchain_transactions#create', project_id: '1', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/projects/1/blockchain_transactions/1').to route_to('api/v1/blockchain_transactions#update', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/projects/1/blockchain_transactions/1').to route_to('api/v1/blockchain_transactions#update', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/projects/1/blockchain_transactions/1').to route_to('api/v1/blockchain_transactions#destroy', id: '1', project_id: '1', format: :json)
    end
  end
end
