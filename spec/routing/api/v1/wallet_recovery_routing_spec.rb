require 'rails_helper'

RSpec.describe Api::V1::WalletRecoveryController, type: :routing do
  describe 'routing' do
    it 'routes to #public_wrapping_key' do
      expect(get: '/api/v1/wallet_recovery/public_wrapping_key').to route_to('api/v1/wallet_recovery#public_wrapping_key', format: :json)
    end

    it 'routes to #recovery' do
      expect(post: '/api/v1/wallet_recovery/recover').to route_to('api/v1/wallet_recovery#recover', format: :json)
    end
  end
end
