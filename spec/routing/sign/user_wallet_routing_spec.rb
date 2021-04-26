require 'rails_helper'

RSpec.describe Sign::UserWalletController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(post: '/sign/user_wallet/new').to route_to('sign/user_wallet#new', format: :json)
    end

    it 'routes to #receive' do
      expect(get: '/sign/user_wallet/receive').to route_to('sign/user_wallet#receive', format: :json)
    end
  end
end
