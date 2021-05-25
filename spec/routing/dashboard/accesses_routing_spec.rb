require 'rails_helper'

RSpec.describe Dashboard::AccessesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/projects/1/dashboard/accesses').to route_to('dashboard/accesses#index', project_id: '1')
    end

    it 'routes to #regenerate_api_key' do
      expect(post: '/projects/1/dashboard/accesses/regenerate_api_key').to route_to('dashboard/accesses#regenerate_api_key', project_id: '1')
    end
  end
end
