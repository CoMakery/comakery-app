require 'rails_helper'

RSpec.describe Api::V1::ProjectRolesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/accounts/1/project_roles').to route_to('api/v1/project_roles#index', account_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/accounts/1/project_roles').to route_to('api/v1/project_roles#create', account_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/accounts/1/project_roles/1').to route_to('api/v1/project_roles#destroy', account_id: '1', id: '1', format: :json)
    end
  end
end
