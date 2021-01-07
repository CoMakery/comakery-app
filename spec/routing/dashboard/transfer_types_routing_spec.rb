require 'rails_helper'

RSpec.describe Dashboard::TransferTypesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/projects/1/dashboard/transfer_categories').to route_to('dashboard/transfer_types#index', project_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/projects/1/dashboard/transfer_types').to route_to('dashboard/transfer_types#create', project_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/projects/1/dashboard/transfer_types/1').to route_to('dashboard/transfer_types#update', id: '1', project_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/projects/1/dashboard/transfer_types/1').to route_to('dashboard/transfer_types#update', id: '1', project_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/projects/1/dashboard/transfer_types/1').to route_to('dashboard/transfer_types#destroy', id: '1', project_id: '1')
    end
  end
end
