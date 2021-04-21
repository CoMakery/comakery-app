require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'XIV. Ethereum wallet flow' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, account: account) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  explanation <<~TEXT
    1. Create a comakery account
    2. Create user provided wallet
    3. Get user provided wallet
  TEXT

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  post '/api/v1/accounts' do
    example '1. Create a comakery account' do
      explanation 'Returns created account data'

      account_params = { managed_account_id: SecureRandom.uuid, email: "me+#{SecureRandom.hex(20)}@example.com", first_name: 'Eva', last_name: 'Smith', nickname: "hunter-#{SecureRandom.hex(20)}", date_of_birth: '1990-01-31', country: 'United States of America' }
      request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'example.org')
      do_request(request)
      expect(status).to eq(201)
    end
  end

  post '/api/v1/accounts/:id/wallets' do
    with_options with_example: true do
      parameter :address, 'wallet address', required: true, type: :string
      parameter :blockchain, "wallet blockchain #{Wallet._blockchains.keys}", required: true, type: :string
      parameter :source, "wallet source #{Wallet.sources.keys}", required: false, type: :string
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallets: [{ blockchain: :ethereum, address: build(:ethereum_address_1), name: 'Wallet' }] } }

      example '2. Create wallet' do
        explanation 'Returns created wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end
  end

  get '/api/v1/accounts/:id/wallets/:wallet_id' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :wallet_id, 'wallet id', required: true, type: :string
    end

    with_options with_example: true do
      response_field :id, 'wallet id', type: :integer
      response_field :address, 'wallet address', type: :string
      response_field :primary_wallet, 'primary wallet', type: :boolean
      response_field :source, "wallet source #{Wallet.sources.keys}", type: :string
      response_field :state, "wallet state #{OreIdAccount.states.keys}", type: :string
      response_field :blockchain, "wallet blockchain #{Wallet._blockchains.keys}", type: :string
      response_field :tokens, 'wallet tokens', type: :array
      response_field :provision_tokens, 'wallet tokens which should be provisioned with state for each token', type: :array
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:wallet_id) { create(:wallet, account: account).id.to_s }

      example '3. Get wallet' do
        explanation 'Returns specified wallet (See INDEX for response details)'

        request = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
