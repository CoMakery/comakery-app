require 'rails_helper'

RSpec.describe Dashboard::AccessesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/projects/1/dashboard/accesses').to route_to('dashboard/accesses#index', project_id: '1')
    end

    it 'routes to #add_admin' do
      expect(post: '/projects/1/dashboard/accesses/add_admin').to route_to('dashboard/accesses#add_admin', project_id: '1')
    end

    it 'routes to #remove_admin' do
      expect(delete: '/projects/1/dashboard/accesses/remove_admin?account_id=2').to route_to('dashboard/accesses#remove_admin', project_id: '1', account_id: '2')
    end

    it 'routes to #regenerate_api_key' do
      expect(post: '/projects/1/dashboard/accesses/regenerate_api_key').to route_to('dashboard/accesses#regenerate_api_key', project_id: '1')
    end
  end
end
