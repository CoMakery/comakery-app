require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'XI. Wallet Recovery' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  explanation 'Get public wrapping key.' \

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  before do
    allow(ENV).to receive(:fetch).with('WALLET_RECOVERY_WRAPPING_KEY', 'default_key').and_return('18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725')
  end

  get '/api/v1/wallet_recovery/public_wrapping_key' do
    context '200' do
      example 'GET' do
        explanation 'Returns public wrapping key generating from a private key using secp256k1 curve.'

        request = build(:api_signed_request, '', api_v1_wallet_recovery_public_wrapping_key_path, 'GET', 'example.org')

        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
