require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'XIII. Full Wallet configurations flow' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, account: account) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  explanation <<~TEXT
    1. Create a comakery account
    2. Create ORE ID wallets
    3. Get password reset link for ETH ORE ID wallet created
    4. Redirect the user to ORE ID reset URL get from step 3
  TEXT

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  post '/api/v1/accounts' do
    example '1. Create a comakery account' do
      explanation 'Returns created account data'

      # 1. Create a comakery account
      account_params = { managed_account_id: SecureRandom.uuid, email: "me+#{SecureRandom.hex(20)}@example.com", first_name: 'Eva', last_name: 'Smith', nickname: "hunter-#{SecureRandom.hex(20)}", date_of_birth: '1990-01-31', country: 'United States of America' }
      request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'example.org')
      do_request(request)
      expect(status).to eq(201)
    end
  end

  post '/api/v1/accounts/:id/wallets' do
    let!(:id) { account.managed_account_id }
    let!(:create_params) { { wallets: [{ blockchain: :ethereum, address: build(:ethereum_address_1), name: 'ETH Wallet' }] } }

    example '2. Create ORE ID wallets' do
      explanation 'Returns created wallets'

      request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
      do_request(request)
      expect(status).to eq(201)
    end
  end

  post '/api/v1/accounts/:id/wallets/:wallet_id/password_reset' do
    let!(:id) { account.managed_account_id }
    let!(:wallet) { create(:ore_id_wallet, account: account) }
    let(:wallet_id) { wallet.id.to_s }
    let!(:redirect_url) { 'localhost' }

    example '3. Get password reset link for ETH ORE ID wallet created' do
      explanation 'Returns reset password url for wallet'

      wallet.ore_id_account.update(account_name: 'ore_id_account_dummy', state: 'unclaimed')

      request = build(:api_signed_request, { redirect_url: redirect_url }, password_reset_api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'POST', 'example.org')

      allow_any_instance_of(OreIdService).to receive(:create_token).and_return('dummy_token')
      allow_any_instance_of(OreIdService).to receive(:remote).and_return({ 'email' => account.email })
      do_request(request)

      expect(status).to eq(200)
    end
  end
end
