# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL
# rubocop:disable RSpec/EmptyExampleGroup

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Accounts' do
  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org') }
  let!(:account) { create(:account) }
  let!(:verification) { create(:verification, account: account) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }
  let!(:project2) { create(:project, mission: active_whitelabel_mission) }

  explanation 'Retrieve and manage account data, follow and unfollow projects.'

  get '/api/v1/accounts/:id' do
    with_options with_example: true do
      parameter :id, 'account id or email', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'id', type: :integer
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
      let!(:id) { account.id }

      example_request 'GET' do
        explanation 'Returns account data'

        expect(status).to eq(200)
      end
    end
  end

  put '/api/v1/accounts/:id' do
    with_options with_example: true do
      parameter :id, 'account id or email', required: true, type: :integer
    end

    with_options scope: :account, with_example: true do
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
      let!(:id) { account.id }
      let!(:first_name) { 'Alex' }

      example_request 'UPDATE' do
        explanation 'Redirects to account data'

        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:id) { account.id }
      let!(:ethereum_wallet) { '0x' }

      example_request 'UPDATE – ERROR' do
        explanation 'Returns an array of errors'

        expect(status).to eq(400)
      end
    end
  end

  get '/api/v1/accounts/:id/follows' do
    with_options with_example: true do
      parameter :id, 'account id or email', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:id) { account.id }
      let!(:page) { 1 }

      before do
        project.interests.create(account: account, specialty: account.specialty)
        project2.interests.create(account: account, specialty: account.specialty)
      end

      example_request 'FOLLOWS' do
        explanation 'Returns an array of project ids'

        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/accounts/:id/follows' do
    with_options with_example: true do
      parameter :id, 'account id or email', required: true, type: :integer
      parameter :project_id, 'project id to follow', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '302' do
      let!(:id) { account.id }
      let!(:project_id) { project.id }

      example_request 'FOLLOW' do
        explanation 'Redirects to account follows'

        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:id) { account.id }
      let!(:project_id) { project.id }

      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      example_request 'FOLLOW – ERROR' do
        explanation 'Returns an array of errors'

        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/accounts/:id/follows/:project_id' do
    with_options with_example: true do
      parameter :id, 'account id or email', required: true, type: :integer
      parameter :project_id, 'project id to unfollow', required: true, type: :integer
    end

    context '302' do
      let!(:id) { account.id }
      let!(:project_id) { project.id }

      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      example_request 'UNFOLLOW' do
        explanation 'Redirects to account follows'

        expect(status).to eq(302)
      end
    end
  end
end
