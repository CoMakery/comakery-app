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
      response_field :state, "wallet state #{OreIdAccount.states.keys}", type: :string
      response_field :blockchain, "wallet blockchain #{Wallet._blockchains.keys}", type: :string
      response_field :tokens, 'wallet tokens', type: :array
      response_field :provision_tokens, 'wallet tokens which should be provisioned with state for each token', type: :array
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
      parameter :tokens_to_provision, 'array of tokens to provision', required: false, type: :string
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallets: [{ blockchain: :bitcoin, address: build(:bitcoin_address_1) }] } }

      example 'CREATE WALLET' do
        explanation 'Returns created wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallets: [{ blockchain: :algorand_test, source: :ore_id }] } }

      example 'CREATE WALLET – ORE_ID' do
        explanation 'Returns created wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let(:token) { create(:asa_token) }
      let(:create_params) { { wallets: [{ blockchain: :algorand_test, source: :ore_id, tokens_to_provision: "[#{token.id}]" }] } }

      example 'CREATE WALLET – ORE_ID WITH PROVISIONING' do
        explanation 'Returns created wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallets: [{ address: build(:bitcoin_address_1) }] } }

      example 'CREATE WALLET – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
        expect(response_body).to eq '{"errors":{"0":{"blockchain":["unknown blockchain value"]}}}'
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

      example 'GET WALLET' do
        explanation 'Returns specified wallet (See INDEX for response details)'

        request = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
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

  post '/api/v1/accounts/:id/wallets/:wallet_id/password_reset' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :wallet_id, 'wallet id', required: true, type: :string
      parameter :redirect_url, 'url to redirect after password change', required: true, type: :string
    end

    with_options with_example: true do
      response_field :resetUrl, 'reset password url', type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:wallet_id) { create(:wallet, source: :ore_id, account: account).id.to_s }
      let!(:redirect_url) { 'localhost' }

      example 'GET RESET PASSWORD URL (ONLY ORE_ID WALLETS)' do
        explanation 'Returns reset password url for wallet'

        request = build(:api_signed_request, { redirect_url: redirect_url }, password_reset_api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'POST', 'example.org')

        allow_any_instance_of(OreIdService).to receive(:create_token).and_return('dummy_token')
        do_request(request)

        expect(status).to eq(200)
      end
    end
  end
end
