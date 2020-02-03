# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'II. Accounts' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, account: account) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }
  let!(:project2) { create(:project, mission: active_whitelabel_mission) }

  explanation 'Retrieve and manage account data, balances, interests.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/accounts/:id' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
    end

    with_options with_example: true do
      response_field :managed_account_id, 'id', type: :string
      response_field :email, 'email', type: :string
      response_field :firstName, 'first name', type: :string
      response_field :lastName, 'last name', type: :string
      response_field :nickname, 'nickname', type: :string
      response_field :imageUrl, 'image url', type: :string
      response_field :country, 'country', type: :string
      response_field :dateOfBirth, 'date of birth', type: :string
      response_field :ethereumWallet, 'ethereum wallet', type: :string
      response_field :qtumWallet, 'qtum Wallet', type: :string
      response_field :cardanoWallet, 'cardano wallet', type: :string
      response_field :bitcoinWallet, 'bitcoin wallet', type: :string
      response_field :eosWallet, 'eos wallet', type: :string
      response_field :tezosWallet, 'tezos wallet', type: :string
      response_field :createdAt, 'account creation timestamp', type: :string
      response_field :updatedAt, 'account update timestamp', type: :string
      response_field :verificationState, 'result of latest AML/KYC verification (passed | failed | unknown)', type: :string, enum: %w[passed failed unknown]
      response_field :verificationDate, 'date of latest AML/KYC verification', type: :string
      response_field :verificationMaxInvestmentUsd, 'max investment approved during latest AML/KYC verification', type: :integer
    end

    context '200' do
      let!(:id) { account.managed_account_id }

      example 'GET' do
        explanation 'Returns account data'

        request = build(:api_signed_request, '', api_v1_account_path(id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/accounts' do
    with_options scope: :account, with_example: true do
      parameter :managed_account_id, 'id', type: :string
      parameter :email, 'email', type: :string, required: true
      parameter :first_name, 'first name', type: :string, required: true
      parameter :last_name, 'last name', type: :string, required: true
      parameter :nickname, 'nickname', type: :string
      parameter :image, 'image', type: :string
      parameter :country, 'counry', type: :string, required: true
      parameter :date_of_birth, 'date of birth', type: :string, required: true
      parameter :ethereum_wallet, 'ethereum wallet', type: :string
      parameter :qtum_wallet, 'qtum wallet', type: :string
      parameter :cardano_wallet, 'cardano wallet', type: :string
      parameter :bitcoin_wallet, 'bitcoin wallet', type: :string
      parameter :eos_wallet, 'eos wallet', type: :string
      parameter :tezos_wallet, 'tezos wallet', type: :string
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '302' do
      let!(:account_params) do
        {
          managed_account_id: SecureRandom.uuid,
          email: "me+#{SecureRandom.hex(20)}@example.com",
          first_name: 'Eva',
          last_name: 'Smith',
          nickname: "hunter-#{SecureRandom.hex(20)}",
          date_of_birth: '1990/01/01',
          country: 'United States of America',
          ethereum_wallet: '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B'
        }
      end

      example 'CREATE' do
        explanation 'Redirects to account data'

        request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:account_params) do
        {
          managed_account_id: SecureRandom.uuid
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  put '/api/v1/accounts/:id' do
    with_options with_example: true do
      parameter :id, 'id', required: true, type: :string
    end

    with_options scope: :account, with_example: true do
      parameter :managed_account_id, 'id', type: :string
      parameter :email, 'email', type: :string
      parameter :first_name, 'first name', type: :string
      parameter :last_name, 'last name', type: :string
      parameter :nickname, 'nickname', type: :string
      parameter :image, 'image', type: :string
      parameter :country, 'counry', type: :string
      parameter :date_of_birth, 'date of birth', type: :string
      parameter :ethereum_wallet, 'ethereum wallet', type: :string
      parameter :qtum_wallet, 'qtum wallet', type: :string
      parameter :cardano_wallet, 'cardano wallet', type: :string
      parameter :bitcoin_wallet, 'bitcoin wallet', type: :string
      parameter :eos_wallet, 'eos wallet', type: :string
      parameter :tezos_wallet, 'tezos wallet', type: :string
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '302' do
      let!(:id) { account.managed_account_id }
      let!(:account_params) do
        {
          first_name: 'Alex'
        }
      end

      example 'UPDATE' do
        explanation 'Redirects to account data'

        request = build(:api_signed_request, { account: account_params }, api_v1_account_path(id: account.managed_account_id), 'PUT', 'example.org')
        do_request(request)
        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }
      let!(:account_params) do
        {
          ethereum_wallet: '0x'
        }
      end

      example 'UPDATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { account: account_params }, api_v1_account_path(id: account.managed_account_id), 'PUT', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  get '/api/v1/accounts/:id/interests' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:page) { 1 }

      before do
        project.interests.create(account: account, specialty: account.specialty)
        project2.interests.create(account: account, specialty: account.specialty)
      end

      example 'INTERESTS' do
        explanation 'Returns an array of project ids'

        request = build(:api_signed_request, '', api_v1_account_interests_path(account_id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/accounts/:id/interests' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :project_id, 'project id to interest', required: true, type: :string
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '302' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      example 'CREATE INTEREST' do
        explanation 'Redirects to account interests'

        request = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_interests_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      example 'CREATE INTEREST – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_interests_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/accounts/:id/interests/:project_id' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :project_id, 'project id to uninterest', required: true, type: :string
    end

    context '302' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      example 'REMOVE INTEREST' do
        explanation 'Redirects to account interests'

        request = build(:api_signed_request, '', api_v1_account_interest_path(account_id: account.managed_account_id, id: project.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(302)
      end
    end
  end

  get '/api/v1/accounts/:id/verifications' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :page, 'page number', type: :integer
    end

    with_options with_example: true do
      response_field :passed, 'verification result', type: :bool
      response_field :verification_type, 'verification type ( aml-kyc accreditation valid-identity ), defaults to aml-kyc', type: :string
      response_field :maxInvestmentUsd, 'maximum investment in us dollars', type: :integer
      response_field :createdAt, 'timestamp', type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:page) { 1 }

      before do
        account.verifications.create(passed: false, max_investment_usd: 100000)
        account.verifications.create(passed: true, max_investment_usd: 10000)
      end

      example 'VERIFICATIONS' do
        explanation 'Returns an array of verifications'

        request = build(:api_signed_request, '', api_v1_account_verifications_path(account_id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/accounts/:id/verifications' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
    end

    with_options scope: :verification, with_example: true do
      parameter :passed, 'verification result', required: true, type: :bool
      parameter :verification_type, 'verification type ( aml-kyc accreditation valid-identity ), defaults to aml-kyc', type: :string
      parameter :max_investment_usd, 'maximum investment in us dollars', required: true, type: :integer
      parameter :created_at, 'timestamp', type: :string
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '302' do
      let!(:id) { account.managed_account_id }

      let!(:verification) do
        {
          passed: 'true',
          max_investment_usd: '10000',
          verification_type: 'aml-kyc',
          created_at: 3.days.ago.to_s
        }
      end

      example 'CREATE VERIFICATION' do
        explanation 'Redirects to account verifications'

        request = build(:api_signed_request, { verification: verification }, api_v1_account_verifications_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }

      let!(:verification) do
        {
          max_investment_usd: '0'
        }
      end

      example 'CREATE VERIFICATION – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { verification: verification }, api_v1_account_verifications_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  get '/api/v1/accounts/:id/token_balances' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
    end

    with_options with_example: true do
      response_field 'total_received', 'total received on platform', type: :integer
      response_field 'blockchain[address]', 'blockchain address', type: :string
      response_field 'blockchain[balance]', 'blockchain balance', type: :string
      response_field 'blockchain[maxBalance]', 'blockchain max balance', type: :integer
      response_field 'blockchain[lockupUntil]', 'blockchain lockup until', type: :string
      response_field 'blockchain[accountFrozen]', 'blockchain account frozen status', type: :bool
      response_field 'token[id]', 'token id', type: :integer
      response_field 'token[name]', 'token name', type: :string
      response_field 'token[symbol]', 'token symbol', type: :string
      response_field 'token[network]', 'token network ( main | ropsten | kovan | rinkeby )', type: :string
      response_field 'token[contractAddress]', 'token contract address', type: :string
      response_field 'token[decimalPlaces]', 'token decimal places', type: :integer
      response_field 'token[logoUrl]', 'token logo url', type: :string
      response_field 'token[createdAt]', 'token creation timestamp', type: :string
      response_field 'token[updatedAt]', 'token update timestamp', type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:token) { create(:token, coin_type: :comakery) }
      let!(:token2) { create(:token, coin_type: :comakery) }
      let!(:account_token_record) { create(:account_token_record, account: account, token: token) }
      let!(:account_token_record2) { create(:account_token_record, account: account, token: token2) }
      let!(:award_type) { create(:award_type, project: create(:project, token: token)) }
      let!(:award_type2) { create(:award_type, project: create(:project, token: token2)) }

      before do
        create(:award, account: account, status: :paid, amount: 1, award_type: award_type)
        create(:award, account: account, status: :paid, amount: 2, award_type: award_type)
        create(:award, account: account, status: :paid, amount: 8, award_type: award_type2)
      end

      example 'TOKEN BALANCES' do
        explanation 'Returns an array of token balances'

        request = build(:api_signed_request, '', api_v1_account_token_balances_path(account_id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
