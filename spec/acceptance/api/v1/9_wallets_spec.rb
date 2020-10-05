require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'IX. Wallets' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  explanation 'Create, delete and retrieve account wallets.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/accounts/:id/wallets' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :page, 'page number', type: :integer
    end

    with_options with_example: true do
      response_field :id, 'wallet id', type: :integer
      response_field :address, 'wallet address', type: :string
      response_field :source, "wallet source #{Wallet.sources.keys}", type: :string
      response_field :state, "wallet state #{Wallet.states.keys}", type: :string
      response_field :blockchain, "wallet blockchain #{Wallet._blockchains.keys}", type: :string
      response_field :tokens, 'wallet tokens', type: :array
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:wallet) { create(:wallet, account: account) }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of wallet objects'

        request = build(:api_signed_request, '', api_v1_account_wallets_path(account_id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/accounts/:id/wallets' do
    with_options with_example: true do
      parameter :address, 'wallet address', required: true, type: :string
      parameter :blockchain, "wallet blockchain #{Wallet._blockchains.keys}", required: true, type: :string
      parameter :source, "wallet source #{Wallet.sources.keys}", required: false, type: :string
      parameter :provision, 'wallet provision type', required: false, type: :string
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallet: { blockchain: :bitcoin, address: build(:bitcoin_address_1) } } }

      example 'CREATE WALLET' do
        explanation 'Returns account wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallet: { blockchain: :bitcoin, address: build(:bitcoin_address_1) } } }

      before do
        account.wallets.create(_blockchain: :bitcoin, address: build(:bitcoin_address_1))
      end

      example 'CREATE WALLET – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/accounts/:id/wallets/:wallet_id' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :wallet_id, 'wallet id to remove', required: true, type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:wallet_id) { create(:wallet, account: account).id.to_s }

      example 'REMOVE WALLET' do
        explanation 'Returns account wallets (See INDEX for response details)'

        request = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
