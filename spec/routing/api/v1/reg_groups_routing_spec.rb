require 'rails_helper'

RSpec.describe Api::V1::RegGroupsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/projects/1/reg_groups').to route_to('api/v1/reg_groups#index', project_id: '1', format: :json)
    end

    it 'routes to #show' do
      expect(get: '/api/v1/projects/1/reg_groups/1').to route_to('api/v1/reg_groups#show', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/projects/1/reg_groups').to route_to('api/v1/reg_groups#create', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/projects/1/reg_groups/1').to route_to('api/v1/reg_groups#destroy', id: '1', project_id: '1', format: :json)
    end
  end
end
