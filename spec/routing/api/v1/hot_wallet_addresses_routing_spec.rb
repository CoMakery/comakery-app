require 'rails_helper'

RSpec.describe Api::V1::HotWalletAddressesController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/api/v1/projects/1/hot_wallet_addresses').to route_to('api/v1/hot_wallet_addresses#create', project_id: '1', format: :json)
    end
  end
end
