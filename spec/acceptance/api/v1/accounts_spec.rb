# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL
# rubocop:disable RSpec/EmptyExampleGroup

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Accounts' do
  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org') }
  let!(:account) { create(:account) }
  let!(:verification) { create(:verification, account: account) }

  explanation 'retrieve and manage account data'

  get '/api/v1/accounts/:id' do
    explanation 'endpoint returns account data on success'

    with_options with_example: true do
      parameter :id, 'account id or email', required: true
    end

    with_options with_example: true do
      response_field :id, 'id'
      response_field :email, 'email'
      response_field :firstName, 'first name'
      response_field :lastName, 'last name'
      response_field :nickname, 'nickname'
      response_field :imageUrl, 'image url'
      response_field :country, 'country'
      response_field :dateOfBirth, 'date of birth'
      response_field :ethereumWallet, 'ethereum wallet'
      response_field :qtumWallet, 'qtum Wallet'
      response_field :cardanoWallet, 'cardano wallet'
      response_field :bitcoinWallet, 'bitcoin wallet'
      response_field :eosWallet, 'eos wallet'
      response_field :tezosWallet, 'tezos wallet'
      response_field :createdAt, 'account creation timestamp'
      response_field :updatedAt, 'account update timestamp'
      response_field :verificationState, 'result of latest AML/KYC verification (passed | failed | unknown)'
      response_field :verificationDate, 'date of latest AML/KYC verification'
      response_field :verificationMaxInvestmentUsd, 'max investment approved during latest AML/KYC verification'
    end

    context '200' do
      let!(:id) { 1 }

      example_request 'get account data' do
        expect(status).to eq(200)
      end
    end
  end

  put '/api/v1/accounts/:id' do
    explanation 'endpoint redirects to account data on success or returns an array of errors'

    with_options with_example: true do
      parameter :id, 'account id or email', required: true
    end

    with_options scope: :account, with_example: true do
      parameter :first_name, 'first name'
      parameter :last_name, 'last name'
      parameter :nickname, 'nickname'
      parameter :image, 'image'
      parameter :country, 'counry'
      parameter :date_of_birth, 'date of birth'
      parameter :ethereum_wallet, 'ethereum wallet'
      parameter :qtum_wallet, 'qtum wallet'
      parameter :cardano_wallet, 'cardano wallet'
      parameter :bitcoin_wallet, 'bitcoin wallet'
      parameter :eos_wallet, 'eos wallet'
      parameter :tezos_wallet, 'rezos wallet'
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '302' do
      let!(:id) { account.id }
      let!(:first_name) { 'Alex' }

      example_request 'update account data – success' do
        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:id) { account.id }
      let!(:ethereum_wallet) { '0x' }

      example_request 'update account data – failure' do
        expect(status).to eq(400)
      end
    end
  end
end
