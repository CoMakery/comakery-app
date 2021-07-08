require 'rails_helper'

RSpec.describe InvitesController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/invites/1').to route_to('invites#show', id: '1')
    end

    it 'routes to #redirect' do
      expect(get: '/invites/1/redirect').to route_to('invites#redirect', id: '1')
    end
  end
end
