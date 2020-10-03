# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'VII. Blockchain Transactions' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:blockchain_transaction) { create(:blockchain_transaction) }
  let!(:project) { blockchain_transaction.blockchain_transactable.project }

  before do
    header 'API-Key', build(:api_key)
    project.update(mission: active_whitelabel_mission)
  end

  explanation 'Generate blockchain transactions for project to process and submit to blockchain.'

  header 'Content-Type', 'application/json'

  post '/api/v1/projects/:project_id/blockchain_transactions' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'transaction id', type: :integer
      response_field :blockchain_transactable_id, 'transactable id', type: :integer
      response_field :amount, 'transaction amount', type: :string
      response_field :destination, 'transaction destination', type: :string
      response_field :source, 'transaction source', type: :string
      response_field :nonce, 'transaction nonce', type: :string
      response_field :contract_address, 'token contract address', type: :string
      response_field :network, 'token network', type: :string
      response_field :tx_hash, 'transaction hash', type: :string
      response_field :tx_raw, 'transaction in HEX', type: :string
      response_field :status, 'transaction status (created pending cancelled succeed failed)', type: :string
      response_field :status_message, 'transaction status message', type: :string
      response_field :createdAt, 'transaction creation timestamp', type: :string
      response_field :updatedAt, 'transaction update timestamp', type: :string
    end

    with_options scope: :transaction, with_example: true do
      parameter :source, 'transaction source wallet address', required: true, type: :string
      parameter :nonce, 'transaction nonce', required: true, type: :string
    end

    with_options with_example: true do
      parameter :blockchain_transactable_id, 'transactable id to generate transaction for', required: false, type: :string
      parameter :blockchain_transactable_type, 'transactable type to generate transaction for – Award (Default), TransferRule, AccountTokenRecord', required: false, type: :string
    end

    context '201' do
      let!(:project_id) { project.id }
      let!(:award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }
      let!(:wallet) { create(:wallet, account: award.account, _blockchain: project.token._blockchain, address: build(:ethereum_address_1)) }

      let!(:transaction) do
        {
          source: build(:ethereum_address_1),
          nonce: 1
        }
      end

      example 'GENERATE TRANSACTION' do
        explanation 'Generates a new blockchain transaction for a transactable and locks the transactable for 10 minutes'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST', 'example.org')

        VCR.use_cassette("infura/#{project.token._blockchain}/#{project.token.contract_address}/contract_init") do
          do_request(request)
        end

        expect(status).to eq(201)
      end

      example 'GENERATE TRANSACTION – WITH PROJECT TRANSACTION API KEY' do
        explanation 'Generates a new blockchain transaction for a transactable and locks the transactable for 10 minutes'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST', 'example.org')

        project.regenerate_api_key
        header 'API-Key', nil
        header 'API-Transaction-Key', project.api_key.key

        VCR.use_cassette("infura/#{project.token.ethereum_network}/#{project.token.ethereum_contract_address}/contract_init") do
          do_request(request)
        end

        expect(status).to eq(201)
      end

      example 'GENERATE TRANSACTION – TRANSACTABLE ID' do
        explanation 'Generates a new blockchain transaction for transactable with supplied id and locks the transactable for 10 minutes'

        request = build(:api_signed_request, { transaction: transaction, blockchain_transactable_id: award.id }, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST', 'example.org')

        VCR.use_cassette("infura/#{project.token._blockchain}/#{project.token.contract_address}/contract_init") do
          do_request(request)
        end

        expect(status).to eq(201)
      end

      example 'GENERATE TRANSACTION – TRANSACTABLE TYPE' do
        explanation 'Generates a new blockchain transaction for transactable with supplied type and locks the transactable for 10 minutes'

        request = build(:api_signed_request, { transaction: transaction, blockchain_transactable_type: create(:transfer_rule, token: project.token) && 'TransferRule' }, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST', 'example.org')

        VCR.use_cassette("infura/#{project.token._blockchain}/#{project.token.contract_address}/contract_init") do
          do_request(request)
        end

        expect(status).to eq(201)
      end
    end

    context '204' do
      let!(:project_id) { project.id }

      let!(:transaction) do
        {
          source: build(:ethereum_address_1),
          nonce: 1
        }
      end

      example 'GENERATE TRANSACTION - NO TRANSFERS' do
        explanation 'Returns empty response if no transactables available for transaction'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(204)
      end
    end
  end

  put '/api/v1/projects/:project_id/blockchain_transactions/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'transaction id', required: true, type: :integer
    end

    with_options scope: :transaction, with_example: true do
      parameter :tx_hash, 'transaction hash', required: true, type: :string
    end

    context '200', vcr: true do
      let!(:project_id) { project.id }
      let!(:id) { blockchain_transaction.id }

      let!(:transaction) do
        {
          tx_hash: blockchain_transaction.tx_hash
        }
      end

      example 'SUBMIT TRANSACTION' do
        explanation 'Marks transaction as pending and returns transaction details, see GENERATE TRANSACTION for response fields'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end

    context '400' do
      let!(:project_id) { project.id }
      let!(:id) { blockchain_transaction.id }

      let!(:transaction) do
        {
          tx_hash: '0x'
        }
      end

      example 'SUBMIT TRANSACTION – HASH MISMATCH' do
        explanation 'Returns an error if submitted transaction hash differs from generated on backend'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/blockchain_transactions/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'transaction id', required: true, type: :integer
    end

    with_options scope: :transaction, with_example: true do
      parameter :tx_hash, 'transaction hash', required: true, type: :string
      parameter :status_message, 'transaction status message', type: :string
    end

    context '200', vcr: true do
      let!(:project_id) { project.id }
      let!(:id) { blockchain_transaction.id }

      let!(:transaction) do
        {
          tx_hash: blockchain_transaction.tx_hash,
          status_message: 'hot wallet error: crash'
        }
      end

      example 'CANCEL TRANSACTION' do
        explanation 'Marks transaction as cancelled and releases transfer for a new transaction, see GENERATE TRANSACTION for response fields'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
