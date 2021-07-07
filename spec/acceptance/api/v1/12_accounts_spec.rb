require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'II. Accounts' do
  include Rails.application.routes.url_helpers

  before do
    Timecop.freeze(Time.zone.local(2021, 4, 6, 10, 5, 0))
    allow_any_instance_of(Comakery::APISignature).to receive(:nonce).and_return('0242d70898bcf3fbb5fa334d1d87804f')
  end

  after do
    Timecop.return
  end

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:static_account, id: 11111111, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, id: 11111112, account: account) }
  let!(:project) { create(:static_project, id: 11111113, mission: active_whitelabel_mission) }
  let!(:project2) { create(:static_project, id: 11111114, mission: active_whitelabel_mission) }

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
      response_field :createdAt, 'account creation timestamp', type: :string
      response_field :updatedAt, 'account update timestamp', type: :string
      response_field :verificationState, 'result of latest AML/KYC verification (passed | failed | unknown)', type: :string, enum: %w[passed failed unknown]
      response_field :verificationDate, 'date of latest AML/KYC verification', type: :string
      response_field :verificationMaxInvestmentUsd, 'max investment approved during latest AML/KYC verification', type: :integer
      response_field :projects, 'list of project ids', type: :array, items: { type: :string }
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
      parameter :date_of_birth, 'date of birth (YYYY-MM-DD)', type: :string, required: true
      parameter :projects, 'list of project ids to subscribe', type: :array, required: false
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '201' do
      let!(:account_params) do
        {
          managed_account_id: '1eeb143f-f0c3-4e85-b66e-92c39edcdef5',
          email: 'me+ca63bd484da019f1938825ffcba6da@example.com',
          first_name: 'Eva',
          last_name: 'Smith',
          nickname: 'hunter-b1f157fc0d5ec93680d7b307d417bc5bd2c',
          date_of_birth: '1990-01-31',
          country: 'United States of America',
          projects: [project.id.to_s]
        }
      end

      example 'CREATE' do
        explanation 'Returns created account data (See GET for response details)'

        request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:account_params) do
        {
          managed_account_id: '37edfd11-6554-4a0c-b104-1a123aa62de1'
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
      parameter :date_of_birth, 'date of birth (YYYY-MM-DD)', type: :string
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:account_params) do
        {
          first_name: 'Alex'
        }
      end

      example 'UPDATE' do
        explanation 'Returns updated account data (See GET for response details)'

        request = build(:api_signed_request, { account: account_params }, api_v1_account_path(id: account.managed_account_id), 'PUT', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }
      let!(:account_params) do
        {
          email: '0x'
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

  get '/api/v1/accounts/:id/project_roles' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:page) { 1 }

      before do
        project.project_roles.create(account: account)
        project2.project_roles.create(account: account)
      end

      example 'PROJECT ROLES' do
        explanation 'Returns an array of project ids'

        request = build(:api_signed_request, '', api_v1_account_project_roles_path(account_id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/accounts/:id/project_roles' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :project_id, 'project id', required: true, type: :string
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      example 'CREATE PROJECT ROLE' do
        explanation 'Returns account project roles (See PROJECT ROLE for response details)'

        request = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_project_roles_path(account_id: account.managed_account_id), 'POST', 'example.org')
        result = do_request(request)
        result[0][:response_body] = [30] if status == 201
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      before do
        project.project_roles.create(account: account)
      end

      example 'CREATE PROJECT ROLE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_project_roles_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/accounts/:id/project_roles/:project_id' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :project_id, 'project id', required: true, type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      before do
        project.project_roles.create(account: account)
      end

      example 'REMOVE PROJECT ROLE' do
        explanation 'Returns account project roles (See PROJECT ROLES for response details)'

        request = build(:api_signed_request, '', api_v1_account_project_role_path(account_id: account.managed_account_id, id: project.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(200)
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

    context '201' do
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
        explanation 'Returns account verifications (See VERIFICATIONS for response details)'
        request = build(:api_signed_request, { verification: verification }, api_v1_account_verifications_path(account_id: account.managed_account_id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
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
      response_field 'total_received_and_accepted_in', 'total received and accepted on platform', type: :integer
      response_field 'blockchain[address]', 'blockchain address', type: :string
      response_field 'blockchain[balance]', 'blockchain balance', type: :string
      response_field 'blockchain[locked_balance]', 'locked blockchain balance', type: :string
      response_field 'blockchain[unlocked_balance]', 'unlocked blockchain balance', type: :string
      response_field 'blockchain[lockup_schedule_ids]', 'lockup schedule ids', type: :array
      response_field 'blockchain[updated_at]', 'blockchain balance', type: :string
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
      let!(:token) { create(:static_token, id: 11111115, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
      let!(:balance) { create(:balance, base_unit_value: 200, token: token, wallet: create(:eth_wallet, account: account)) }
      let!(:award_type) { create(:award_type, project: create(:project, token: token)) }

      before do
        create(:award, account: account, status: :paid, amount: 1, award_type: award_type)
        create(:award, account: account, status: :paid, amount: 2, award_type: award_type)
      end

      example 'TOKEN BALANCES' do
        explanation 'Returns an array of token balances'

        request = build(:api_signed_request, '', api_v1_account_token_balances_path(account_id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/accounts/:id/transfers' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:page) { 1 }
      let(:award_type) { create(:award_type, project: project) }
      let(:transfer_type) { create(:transfer_type, id: 11111116, project: award_type.project) }

      before do
        create(:award, id: 11111117, account: account, status: :paid, amount: 1, award_type: award_type, transfer_type: transfer_type)
      end

      example 'TRANSFERS' do
        explanation 'Returns an array of transactions for the account'

        request = build(:api_signed_request, '', api_v1_account_transfers_path(account_id: account.managed_account_id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
