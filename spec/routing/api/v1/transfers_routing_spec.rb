require 'rails_helper'

RSpec.describe Api::V1::TransfersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/projects/1/transfers').to route_to('api/v1/transfers#index', project_id: '1', format: :json)
    end

    it 'routes to #show' do
      expect(get: '/api/v1/projects/1/transfers/1').to route_to('api/v1/transfers#show', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/projects/1/transfers').to route_to('api/v1/transfers#create', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/projects/1/transfers/1').to route_to('api/v1/transfers#destroy', id: '1', project_id: '1', format: :json)
    end
  end
end
