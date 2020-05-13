require 'rails_helper'

RSpec.describe Auth::EthController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/auth/eth/new').to route_to('auth/eth#new', format: :json)
    end

    it 'routes to #create via POST' do
      expect(post: '/auth/eth').to route_to('auth/eth#create', format: :json)
    end
  end
end
