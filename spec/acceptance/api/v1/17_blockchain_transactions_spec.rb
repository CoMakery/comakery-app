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
      parameter :blockchain_transactable_type, 'transactable type to generate transaction for (awards, transfer_rules, account_token_records)', required: false, type: :string
      parameter :blockchain_transactable_id, 'transactable id of transactable type to generate transaction for', required: false, type: :string
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
          result = do_request(request)
          if status == 201
            result[0][:request_headers]['Api-Transaction-Key'] = 'F957nHNpAp3Ja9cQ3IEEbvhryjoaFr6T'
            result[0][:request_path] = '/api/v1/projects/6/blockchain_transactions'
            result[0][:request_body] = {
                                          "body": {
                                            "data": {
                                              "transaction": {
                                                "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                                "nonce": 1
                                              }
                                            },
                                            "url": "http://example.org/api/v1/projects/6/blockchain_transactions",
                                            "method": "POST",
                                            "nonce": "0b50829f4e37c5e3003939befcc0a678",
                                            "timestamp": "1617700095"
                                          },
                                          "proof": {
                                            "type": "Ed25519Signature2018",
                                            "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                            "signature": "hNj4HQ8h/m+9wjrigw0DbwDCQEa0pHBqGZVNTG0Wf5QICt6DO4AzFy53hQvC08v+f0SLUMdA7KdLqFjlB8rQBw=="
                                          }
                                        }
            result[0][:response_headers]['ETag'] = 'W/"da6007a83bbd78f85125daef93352ae6"'
            result[0][:response_body] = {
                                          "id": 8,
                                          "blockchainTransactableId": 8,
                                          "destination": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                          "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                          "amount": 50,
                                          "nonce": 1,
                                          "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                          "network": "ethereum_ropsten",
                                          "txHash": "0xcee7721cf9a5ecee1b61ddeb1901685197c9b7e5368938fede61818189eb81d1",
                                          "txRaw": "0xf86701822710830186a0941d1592c28fff3d3e71b1d29e31147846026a0a3780b844a9059cbb00000000000000000000000042d00fc2efdace4859187de4865df9baa320d5db0000000000000000000000000000000000000000000000000000000000000032808080",
                                          "status": "created",
                                          "statusMessage": nil,
                                          "createdAt": "2021-04-06T09:08:15.839Z",
                                          "updatedAt": "2021-04-06T09:08:15.839Z",
                                          "syncedAt": nil
                                        }
          end
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
          result = do_request(request)
          if status == 201
            result[0][:request_headers]['Api-Transaction-Key'] = 'F957nHNpAp3Ja9cQ3IEEbvhryjoaFr6T'
            result[0][:request_path] = '/api/v1/projects/5/blockchain_transactions'
            result[0][:request_body] = {
                                          "body": {
                                            "data": {
                                              "transaction": {
                                                "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                                "nonce": 1
                                              }
                                            },
                                            "url": "http://example.org/api/v1/projects/5/blockchain_transactions",
                                            "method": "POST",
                                            "nonce": "e36ca662985dae24641d19ec5e277441",
                                            "timestamp": "1617700094"
                                          },
                                          "proof": {
                                            "type": "Ed25519Signature2018",
                                            "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                            "signature": "Hy0cojS9wr/1Uew2mo0Oh1QRrk4jmu7dJ4vI61kjQPxexlUIXBGgeNuJSs28lv0QfcPB/Aj8YXh3w1mH4btCBA=="
                                          }
                                        }
            result[0][:response_headers]['ETag'] = 'W/"aabf24c719254ca116b09b4f27caff41"'
            result[0][:response_body] = {
                                          "id": 6,
                                          "blockchainTransactableId": 6,
                                          "destination": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                          "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                          "amount": 50,
                                          "nonce": 1,
                                          "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                          "network": "ethereum_ropsten",
                                          "txHash": "0xcee7721cf9a5ecee1b61ddeb1901685197c9b7e5368938fede61818189eb81d1",
                                          "txRaw": "0xf86701822710830186a0941d1592c28fff3d3e71b1d29e31147846026a0a3780b844a9059cbb00000000000000000000000042d00fc2efdace4859187de4865df9baa320d5db0000000000000000000000000000000000000000000000000000000000000032808080",
                                          "status": "created",
                                          "statusMessage": nil,
                                          "createdAt": "2021-04-06T09:08:14.589Z",
                                          "updatedAt": "2021-04-06T09:08:14.589Z",
                                          "syncedAt": nil
                                        }
          end
        end

        expect(status).to eq(201)
      end

      example 'GENERATE TRANSACTION – TRANSACTABLE TYPE' do
        explanation 'Generates a new blockchain transaction for transactable with supplied type and locks the transactable for 10 minutes'
        create(:transfer_rule, token: project.token)

        request = build(:api_signed_request, { transaction: transaction, blockchain_transactable_type: 'transfer_rules' }, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST', 'example.org')

        VCR.use_cassette("infura/#{project.token._blockchain}/#{project.token.contract_address}/contract_init") do
          result = do_request(request)
          if status == 201
            result[0][:request_headers]['Api-Transaction-Key'] = 'F957nHNpAp3Ja9cQ3IEEbvhryjoaFr6T'
            result[0][:request_path] = '/api/v1/projects/7/blockchain_transactions'
            result[0][:request_body] = {
                                          "body": {
                                            "data": {
                                              "transaction": {
                                                "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                                "nonce": 1
                                              },
                                              "blockchain_transactable_type": "transfer_rules"
                                            },
                                            "url": "http://example.org/api/v1/projects/7/blockchain_transactions",
                                            "method": "POST",
                                            "nonce": "5001d013660afe3163468fd86b2b57c1",
                                            "timestamp": "1617700097"
                                          },
                                          "proof": {
                                            "type": "Ed25519Signature2018",
                                            "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                            "signature": "VpJhAGWvLMvPwkPmWJKrD7bH/WTNEn4ceb/aQ8zNAe3/CcyjltxdjmdPNmgs4vpPbPBHT/58t7hRZS/20ZTODw=="
                                          }
                                        }
            result[0][:response_headers]['ETag'] = 'W/"1500bb84198cd5cabd992a13a2d691fe"'
            result[0][:response_body] = {
                                          "id": 10,
                                          "blockchainTransactableId": 1,
                                          "destination": nil,
                                          "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                          "amount": nil,
                                          "nonce": 1,
                                          "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                          "network": "ethereum_ropsten",
                                          "txHash": "0x41601920cf11532a3cf40fab8bac915ebceb28e57689b333c1d3f93749633b47",
                                          "txRaw": "0xf88701822710830186a0941d1592c28fff3d3e71b1d29e31147846026a0a3780b864e98a0c6400000000000000000000000000000000000000000000000000000000000003fb00000000000000000000000000000000000000000000000000000000000003fc00000000000000000000000000000000000000000000000000000000606ad381808080",
                                          "status": "created",
                                          "statusMessage": nil,
                                          "createdAt": "2021-04-06T09:08:17.180Z",
                                          "updatedAt": "2021-04-06T09:08:17.180Z",
                                          "syncedAt": nil
                                        }
          end
        end
        expect(status).to eq(201)
      end

      example 'GENERATE TRANSACTION – TRANSACTABLE TYPE AND TRANSACTABLE ID' do
        explanation 'Generates a new blockchain transaction for transactable with supplied type and id and locks the transactable for 10 minutes'
        t = create(:transfer_rule, token: project.token)

        request = build(:api_signed_request, { transaction: transaction, blockchain_transactable_type: 'transfer_rules', blockchain_transactable_id: t.id }, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST', 'example.org')

        VCR.use_cassette("infura/#{project.token._blockchain}/#{project.token.contract_address}/contract_init") do
          result = do_request(request)
          if status == 201
            result[0][:request_headers]['Api-Transaction-Key'] = 'F957nHNpAp3Ja9cQ3IEEbvhryjoaFr6T'
            result[0][:request_path] = '/api/v1/projects/8/blockchain_transactions'
            result[0][:request_body] = {
                                          "body": {
                                            "data": {
                                              "transaction": {
                                                "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                                "nonce": 1
                                              },
                                              "blockchain_transactable_type": "transfer_rules",
                                              "blockchain_transactable_id": 2
                                            },
                                            "url": "http://example.org/api/v1/projects/8/blockchain_transactions",
                                            "method": "POST",
                                            "nonce": "0390e7656c4b18307f64949ba197953c",
                                            "timestamp": "1617700098"
                                          },
                                          "proof": {
                                            "type": "Ed25519Signature2018",
                                            "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                            "signature": "Yi1crz8M3O2Z7ZluF4SnuVYv4bdvRmZYHj9mfh1X2CS73ME4wukTqU+W4RstcfE7VCfIE+t6/+Pd2EuLs6tJAQ=="
                                          }
                                        }
            result[0][:response_headers]['ETag'] = 'W/"c8a83d77600a5b20e70a4b594bb8723d"'
            result[0][:response_body] = {
                                          "id": 12,
                                          "blockchainTransactableId": 2,
                                          "destination": nil,
                                          "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                          "amount": nil,
                                          "nonce": 1,
                                          "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                          "network": "ethereum_ropsten",
                                          "txHash": "0x16e0d709dec7b508b200e7d22117d8b0da2b001491b37038c026426f91b1fd87",
                                          "txRaw": "0xf88701822710830186a0941d1592c28fff3d3e71b1d29e31147846026a0a3780b864e98a0c6400000000000000000000000000000000000000000000000000000000000003fe00000000000000000000000000000000000000000000000000000000000003ff00000000000000000000000000000000000000000000000000000000606ad382808080",
                                          "status": "created",
                                          "statusMessage": nil,
                                          "createdAt": "2021-04-06T09:08:18.508Z",
                                          "updatedAt": "2021-04-06T09:08:18.508Z",
                                          "syncedAt": nil
                                        }              
          end
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
        result = do_request(request)
        if status == 204
          result[0][:request_headers]['Api-Transaction-Key'] = 'F957nHNpAp3Ja9cQ3IEEbvhryjoaFr6T'
          result[0][:request_path] = '/api/v1/projects/9/blockchain_transactions'
          result[0][:request_body] = {
                                        "body": {
                                          "data": {
                                            "transaction": {
                                              "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                              "nonce": 1
                                            }
                                          },
                                          "url": "http://example.org/api/v1/projects/9/blockchain_transactions",
                                          "method": "POST",
                                          "nonce": "77c3f8cc4ab40b940ddc35dd700b7f92",
                                          "timestamp": "1617700099"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "fCldHM+eSSkXVmScC8aATomri9cMcSWDY+/0awPPc+9ZkqZtElgbed0ufm3GFBlmrrH4MvXGbiMRuskSmg0IAw=="
                                        }
                                      }
        end
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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/2/blockchain_transactions/2'
          result[0][:request_body] = {
                                        "body": {
                                          "data": {
                                            "transaction": {
                                              "tx_hash": "0x54f6c3ddd3dfca7aa5a6b46c4e095a245f1d53424379517a8b64c50bd4768fb2"
                                            }
                                          },
                                          "url": "http://example.org/api/v1/projects/2/blockchain_transactions/2",
                                          "method": "PUT",
                                          "nonce": "52614e543ab3ce9f8fd1e06f2083d801",
                                          "timestamp": "1617705747"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "B/AGqdewgTJmtJyydWgHEpnd1S5npZ5e6vKtra6NmXE7Kcg9rGXbJyKCzMYfRcUeO5WjOzwyE3yuGe0z8dU9Dw=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"6a7e7a2d84ced26ed7168958391a5b22"'
          result[0][:response_body] = {
                                        "id": 2,
                                        "blockchainTransactableId": 2,
                                        "destination": "0xB4252b39f8506A711205B0b1C4170f0034065b46",
                                        "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                        "amount": 1,
                                        "nonce": 248739,
                                        "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                        "network": "ethereum_ropsten",
                                        "txHash": "0x54f6c3ddd3dfca7aa5a6b46c4e095a245f1d53424379517a8b64c50bd4768fb2",
                                        "txRaw": "0xf86a8303cba3822710830186a0941d1592c28fff3d3e71b1d29e31147846026a0a3780b844a9059cbb000000000000000000000000b4252b39f8506a711205b0b1c4170f0034065b460000000000000000000000000000000000000000000000000000000000000001808080",
                                        "status": "pending",
                                        "statusMessage": nil,
                                        "createdAt": "2021-04-06T10:42:27.563Z",
                                        "updatedAt": "2021-04-06T10:42:27.701Z",
                                        "syncedAt": nil
                                      }
        end
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
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/projects/1/blockchain_transactions/1'
          result[0][:request_body] = {
                                      "body": {
                                        "data": {
                                          "transaction": {
                                            "tx_hash": "0x"
                                          }
                                        },
                                        "url": "http://example.org/api/v1/projects/1/blockchain_transactions/1",
                                        "method": "PUT",
                                        "nonce": "85f72e53ea0e3dbd61bb9e90bfea9873",
                                        "timestamp": "1617705746"
                                      },
                                      "proof": {
                                        "type": "Ed25519Signature2018",
                                        "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                        "signature": "bAUgi2hmbIzwH4zHuuUAkVWlvgrKY+w7dvePxnfyBO/mN76MMf4xlYNEl1ledMgeehmilVWQcrhBn0KRjdovBw=="
                                      }
                                    }
        end
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
      parameter :failed, 'marks transaction as failed, to exclude the transactable from further transactions', type: :string
    end

    context '200', vcr: true do
      let!(:project_id) { project.id }
      let!(:id) { blockchain_transaction.id }

      let!(:transaction) do
        {
          tx_hash: blockchain_transaction.tx_hash,
          status_message: 'hot wallet error: insufficient balance'
        }
      end

      example 'CANCEL TRANSACTION' do
        explanation 'Marks transaction as cancelled and releases transfer for a new transaction, see GENERATE TRANSACTION for response fields'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/2/blockchain_transactions/2'
          result[0][:request_body] = {
                                        "body": {
                                          "data": {
                                            "transaction": {
                                              "tx_hash": "0xebec2f7c55204e2f4aadebf9473e5f197d3842aa5faaa9a3708e6534b924935f",
                                              "status_message": "hot wallet error: insufficient balance"
                                            }
                                          },
                                          "url": "http://example.org/api/v1/projects/2/blockchain_transactions/2",
                                          "method": "DELETE",
                                          "nonce": "b2a750c099e4ade6add7c044b7488d38",
                                          "timestamp": "1617700090"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "kE9/Gh5PLrJNxp4oU16KZpMEaHfj3UEtS3yfFuTm6iKbUVh4PBridVHuaQpFwcuwVjxr/0av0wktKWSJcxBdBg=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"3eba2da3883d3661f3cdf6c56bbaab6b"'
          result[0][:response_body] = {
                                        "id": 2,
                                        "blockchainTransactableId": 2,
                                        "destination": "0xB4252b39f8506A711205B0b1C4170f0034065b46",
                                        "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                        "amount": 1,
                                        "nonce": 425616,
                                        "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                        "network": "ethereum_ropsten",
                                        "txHash": "0xebec2f7c55204e2f4aadebf9473e5f197d3842aa5faaa9a3708e6534b924935f",
                                        "txRaw": "0xf86a83067e90822710830186a0941d1592c28fff3d3e71b1d29e31147846026a0a3780b844a9059cbb000000000000000000000000b4252b39f8506a711205b0b1c4170f0034065b460000000000000000000000000000000000000000000000000000000000000001808080",
                                        "status": "cancelled",
                                        "statusMessage": "hot wallet error: insufficient balance",
                                        "createdAt": "2021-04-06T09:08:10.530Z",
                                        "updatedAt": "2021-04-06T09:08:10.659Z",
                                        "syncedAt": nil
                                      }
        end
        expect(status).to eq(200)
      end
    end

    context '200', vcr: true do
      let!(:project_id) { project.id }
      let!(:id) { blockchain_transaction.id }

      let!(:transaction) do
        {
          tx_hash: blockchain_transaction.tx_hash,
          status_message: 'hot wallet error: unprocessable tx',
          failed: 'true'
        }
      end

      example 'FAIL TRANSACTION' do
        explanation 'Marks transaction as failed and excludes transfer from further transactions, see GENERATE TRANSACTION for response fields'

        request = build(:api_signed_request, { transaction: transaction }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_headers]['Api-Transaction-Key'] = 'F957nHNpAp3Ja9cQ3IEEbvhryjoaFr6T'
          result[0][:request_path] = '/api/v1/projects/1/blockchain_transactions/1'
          result[0][:request_body] =  {
                                        "body": {
                                          "data": {
                                            "transaction": {
                                              "tx_hash": "0x5cefaae9422fe2161b6a2428e1b4636f20b6d8bcb9e3987a5e28ffdb7743e218",
                                              "status_message": "hot wallet error: unprocessable tx",
                                              "failed": "true"
                                            }
                                          },
                                          "url": "http://example.org/api/v1/projects/1/blockchain_transactions/1",
                                          "method": "DELETE",
                                          "nonce": "442e0e3ab2fd5ee67486e7f080dff288",
                                          "timestamp": "1617700089"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "dBVpHcITMOETygfhUX3XUNsJHOKwTVBqm22/lr9fIitA20KxoTZm0ZVuRIO43+UjCwKErRLo0ZaGi6NpjMg2CQ=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"6730b8d25cb57559c7d21e316f563f4e"'
          result[0][:response_body] = {
                                        "id": 1,
                                        "blockchainTransactableId": 1,
                                        "destination": "0xB4252b39f8506A711205B0b1C4170f0034065b46",
                                        "source": "0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB",
                                        "amount": 1,
                                        "nonce": 831669,
                                        "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                        "network": "ethereum_ropsten",
                                        "txHash": "0x5cefaae9422fe2161b6a2428e1b4636f20b6d8bcb9e3987a5e28ffdb7743e218",
                                        "txRaw": "0xf86a830cb0b5822710830186a0941d1592c28fff3d3e71b1d29e31147846026a0a3780b844a9059cbb000000000000000000000000b4252b39f8506a711205b0b1c4170f0034065b460000000000000000000000000000000000000000000000000000000000000001808080",
                                        "status": "failed",
                                        "statusMessage": "hot wallet error: unprocessable tx",
                                        "createdAt": "2021-04-06T09:08:09.043Z",
                                        "updatedAt": "2021-04-06T09:08:09.207Z",
                                        "syncedAt": nil
                                      }
        end
        expect(status).to eq(200)
      end
    end
  end
end
