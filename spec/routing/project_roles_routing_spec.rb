require 'rails_helper'

RSpec.describe ProjectRolesController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/projects/1/project_roles').to route_to('project_roles#create', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/projects/1/project_roles/2').to route_to('project_roles#destroy',
                                                                project_id: '1',
                                                                id: '2',
                                                                format: :json)
    end
  end
end
