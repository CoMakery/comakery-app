require 'rails_helper'

describe 'Wallet configuration flow', type: :request do
  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'www.example.com', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, account: account) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }
  let(:headers) { { 'Content-Type' => 'application/json', 'API-Key' => build(:api_key) } }

  it 'runs successfully' do
    # 1. Create a comakery account
    account_params = { managed_account_id: SecureRandom.uuid, email: 'create_a_wallet@for_me.com', first_name: 'Eva', last_name: 'Smith', nickname: 'wallet creation test', date_of_birth: '1990-01-31', country: 'United States of America' }
    request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'www.example.com')

    post api_v1_accounts_path, params: request.to_json, headers: headers

    expect(status).to eq(201)
    created_account = JSON.parse(response.body)
    expect(created_account['managedAccountId']).to be_present

    # 2. Create ORE ID wallets
    wallet_params = { wallets: [{ blockchain: :ethereum_ropsten, source: :ore_id, name: 'ETH Wallet' }] }
    wallet_creation_path = api_v1_account_wallets_path(account_id: created_account['managedAccountId'])
    request = build(:api_signed_request, wallet_params, wallet_creation_path, 'POST', 'www.example.com')

    post wallet_creation_path, params: request.to_json, headers: headers
    expect(status).to eq(201)
    created_wallet = JSON.parse(response.body).first
    expect(created_wallet['address']).to be nil
    expect(created_wallet['state']).to eq 'pending'

    ore_id_account = OreIdAccount.last
    expect(ore_id_account.account_name).to be nil
    expect(ore_id_account.state).to eq 'pending'

    # to use recorded API call
    ore_id_account.update temp_password: '71a89055e394c22e0b9aaa05bfed628ea5a6b91ca1be990070abc0127ef23d2d!'

    VCR.use_cassette('wallet_configuration_flow/sync_ore_id', record: :once) do
      # In real app it runs from a job
      ore_id_account.create_remote!
    end

    ore_id_account.reload
    expect(ore_id_account.account_name).to eq 'ore1ro5f2slw' # get from ore id
    expect(ore_id_account.state).to eq 'unclaimed'

    # 3. Get password reset link for ETH ORE ID wallet created
    reset_password_params = { redirect_url: 'localhost' }
    password_reset_path = password_reset_api_v1_account_wallet_path(account_id: created_account['managedAccountId'], id: created_wallet['id'])
    request = build(:api_signed_request, reset_password_params, password_reset_path, 'POST', 'www.example.com')

    VCR.use_cassette('wallet_configuration_flow/password_reset', record: :once, match_requests_on: %i[method uri]) do
      post password_reset_path, params: request.to_json, headers: headers
    end

    expect(status).to eq(200)
    reset_url_response = JSON.parse(response.body)
    expect(reset_url_response['resetUrl']).to start_with 'https://service.oreid.io/reset-password?app_access_token='

    expect(ore_id_account.reload.state).to eq 'unclaimed'
  end
end
