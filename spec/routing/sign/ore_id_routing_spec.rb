require 'rails_helper'

RSpec.describe Sign::OreIdController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/sign/ore_id/new').to route_to('sign/ore_id#new', format: :json)
    end

    it 'routes to #receive' do
      expect(get: '/sign/ore_id/receive').to route_to('sign/ore_id#receive', format: :json)
    end
  end
end
