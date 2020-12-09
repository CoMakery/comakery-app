require 'rails_helper'

RSpec.describe Auth::OreIdController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(post: '/auth/ore_id/new').to route_to('auth/ore_id#new', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/auth/ore_id/destroy').to route_to('auth/ore_id#destroy', format: :json)
    end

    it 'routes to #receive' do
      expect(get: '/auth/ore_id/receive').to route_to('auth/ore_id#receive', format: :json)
    end
  end
end
