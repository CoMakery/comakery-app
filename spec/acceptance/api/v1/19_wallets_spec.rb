require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'IX. Wallets' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  explanation 'Create, update, delete and retrieve account wallets.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/accounts/:id/wallets' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :page, 'page number', type: :integer
    end

    with_options with_example: true do
      response_field :id, 'wallet id', type: :integer
      response_field :name, 'wallet name', type: :string
      response_field :address, 'wallet address', type: :string
      response_field :primary_wallet, 'primary wallet', type: :boolean
      response_field :source, "wallet source #{Wallet.sources.keys}", type: :string
      response_field :state, "wallet state #{OreIdAccount.states.keys}", type: :string
      response_field :blockchain, "wallet blockchain #{Wallet._blockchains.keys}", type: :string
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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/f538a7ed-d62c-4e1d-b88e-ff1812303535/wallets?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Faccounts%2Ff538a7ed-d62c-4e1d-b88e-ff1812303535%2Fwallets&body[method]=GET&body[nonce]=318f2ca7a82042471fd6087247363373&body[timestamp]=1617707671&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=74Hv%2FjNdrClVm9GMyxh3mr7bD3ELqcxft39rvSM%2B7FzLyu0%2FqcHug24VPBEEmlYxshPzsFmQ5995xlIpnkkYCQ%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: { 'data' => '', 'url' => 'http://example.org/api/v1/accounts/f538a7ed-d62c-4e1d-b88e-ff1812303535/wallets', 'method' => 'GET', 'nonce' => '318f2ca7a82042471fd6087247363373', 'timestamp' => '1617707671' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => '74Hv/jNdrClVm9GMyxh3mr7bD3ELqcxft39rvSM+7FzLyu0/qcHug24VPBEEmlYxshPzsFmQ5995xlIpnkkYCQ==' } }

          result[0][:response_headers]['ETag'] = 'W/"97f43e95fa090161fe55c2ac83451681"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 11:14:31 GMT'
          result[0][:response_body] = [
            {
              "id": 24,
              "name": 'Wallet',
              "address": '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt',
              "primaryWallet": true,
              "source": 'user_provided',
              "state": 'ok',
              "createdAt": '2021-04-06T11:14:31.564Z',
              "updatedAt": '2021-04-06T11:14:31.564Z',
              "blockchain": 'bitcoin',
              "provisionTokens": []
            }
          ]
        end
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/accounts/:id/wallets' do
    with_options with_example: true do
      parameter :address, 'wallet address', required: true, type: :string
      parameter :blockchain, "wallet blockchain #{Wallet._blockchains.keys}", required: true, type: :string
      parameter :source, "wallet source #{Wallet.sources.keys}", required: false, type: :string
      parameter :tokens_to_provision, 'array of params to tokens provision', required: false, type: :array
      parameter 'tokens_to_provision["token_id"]', 'token_id is required if tokens_to_provision provided', required: true, type: :string
      parameter 'tokens_to_provision["max_balance"]', 'max_balance is required for security tokens only', required: false, type: :string
      parameter 'tokens_to_provision["lockup_until"]', 'lockup_until is required for security tokens only', required: false, type: :string
      parameter 'tokens_to_provision["reg_group_id"]', 'reg_group_id is required for security tokens only', required: false, type: :string
      parameter 'tokens_to_provision["account_frozen"]', 'account_frozen is required for security tokens only', required: false, type: :string
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallets: [{ blockchain: :bitcoin, address: build(:bitcoin_address_1), name: 'Wallet' }] } }

      example 'CREATE WALLET' do
        explanation 'Returns created wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/accounts/76bcd9d0-a041-44ce-aae2-8daa6ff08dcf/wallets'
          result[0][:request_body] = {
            "body": {
              "data": {
                "wallets": [
                  {
                    "blockchain": 'bitcoin',
                    "address": '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt',
                    "name": 'Wallet'
                  }
                ]
              },
              "url": 'http://example.org/api/v1/accounts/76bcd9d0-a041-44ce-aae2-8daa6ff08dcf/wallets',
              "method": 'POST',
              "nonce": 'eaa10347537e8e3506364d5ddbb89ded',
              "timestamp": '1617707669'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'H+GSIW5GQTG7HvHfHrG+SbgzBBl5spaq4dxoAoodjqOTMhmMwQm0pMG6ziuYJNRfYSGNLOJVf12TAQAzFyv2Cw=='
            }
          }

          result[0][:response_headers]['ETag'] = 'W/"80c0aab9bd4ceeafdd4cd027433233ed"'
          result[0][:response_body] = [
            {
              "id": 21,
              "name": 'Wallet',
              "address": '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt',
              "primaryWallet": true,
              "source": 'user_provided',
              "state": 'ok',
              "createdAt": '2021-04-06T11:14:30.200Z',
              "updatedAt": '2021-04-06T11:14:30.200Z',
              "blockchain": 'bitcoin',
              "provisionTokens": []
            }
          ]
        end
        expect(status).to eq(201)
      end
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallets: [{ blockchain: :algorand_test, source: :ore_id, name: 'Wallet' }] } }

      example 'CREATE WALLET – ORE_ID' do
        explanation 'Returns created wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/accounts/37ec01ee-6c21-49b8-80c5-92f184db4632/wallets'
          result[0][:request_body] = {
            "body": {
              "data": {
                "wallets": [
                  {
                    "blockchain": 'algorand_test',
                    "source": 'ore_id',
                    "name": 'Wallet'
                  }
                ]
              },
              "url": 'http://example.org/api/v1/accounts/37ec01ee-6c21-49b8-80c5-92f184db4632/wallets',
              "method": 'POST',
              "nonce": '9077d6f5299ff3930d168af94bcc7a78',
              "timestamp": '1617707668'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'mlxybyFSROStKmubTudTVuzEAEnTfJrb2vOE0o9Vvuq8WyC81rmP0p8Euo7DDlrd7CUp+2kOUC4GiTcm468JBg=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"f28e5a96c256de35fb5ebf9ad6da86f8"'
          result[0][:response_body] = [
            {
              "id": 20,
              "name": 'Wallet',
              "address": nil,
              "primaryWallet": true,
              "source": 'ore_id',
              "state": 'pending',
              "createdAt": '2021-04-06T11:14:29.062Z',
              "updatedAt": '2021-04-06T11:14:29.062Z',
              "blockchain": 'algorand_test',
              "provisionTokens": []
            }
          ]
        end
        expect(status).to eq(201)
      end
    end

    context '201' do
      let!(:id) { account.managed_account_id }
      let(:asa_token) { create(:asa_token) }
      let(:ast_token) { create(:algo_sec_token) }
      let(:reg_group) { create(:reg_group, token: ast_token) }
      let(:tokens_to_provision) do
        [
          { token_id: asa_token.id.to_s },
          { token_id: ast_token.id.to_s, max_balance: '100', lockup_until: '1', reg_group_id: reg_group.id.to_s, account_frozen: 'false' }
        ]
      end
      let(:create_params) { { wallets: [{ blockchain: :algorand_test, source: :ore_id, tokens_to_provision: tokens_to_provision, name: 'Wallet name' }] } }

      example 'CREATE WALLET – ORE_ID WITH PROVISIONING' do
        explanation 'Returns created wallets (See INDEX for response details)'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/accounts/c6f272bb-f644-4539-9880-b15c449b9c57/wallets'
          result[0][:request_body] = {
            "tokens_to_provision": [
              {
                "token_id": '91'
              },
              {
                "token_id": '92',
                "max_balance": '100',
                "lockup_until": '1',
                "reg_group_id": '37',
                "account_frozen": 'false'
              }
            ],
            "body": {
              "data": {
                "wallets": [
                  {
                    "blockchain": 'algorand_test',
                    "source": 'ore_id',
                    "tokens_to_provision": [
                      {
                        "token_id": '91'
                      },
                      {
                        "token_id": '92',
                        "max_balance": '100',
                        "lockup_until": '1',
                        "reg_group_id": '37',
                        "account_frozen": 'false'
                      }
                    ],
                    "name": 'Wallet name'
                  }
                ]
              },
              "url": 'http://example.org/api/v1/accounts/c6f272bb-f644-4539-9880-b15c449b9c57/wallets',
              "method": 'POST',
              "nonce": 'cfce46450dccd10f9e7d6187b941d18a',
              "timestamp": '1617707668'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": '4fN1F+jATkNe+sVwIG8PyEir1TdXT70F1iCInS2pYakvVBuXCiBeX4ogvCkEhVb+CNkOzBTkDQSrV++Fk6x2AA=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"eebfff3973e24799edebf13f3965f43c"'
          result[0][:response_body] = [
            {
              "id": 19,
              "name": 'Wallet name',
              "address": nil,
              "primaryWallet": true,
              "source": 'ore_id',
              "state": 'pending',
              "createdAt": '2021-04-06T11:14:28.222Z',
              "updatedAt": '2021-04-06T11:14:28.222Z',
              "blockchain": 'algorand_test',
              "provisionTokens": [
                {
                  "tokenId": 91,
                  "state": 'pending'
                },
                {
                  "tokenId": 92,
                  "state": 'pending'
                }
              ]
            }
          ]
        end
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:id) { account.managed_account_id }
      let!(:create_params) { { wallets: [{ address: build(:bitcoin_address_1), name: 'Wallet' }] } }

      example 'CREATE WALLET – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/accounts/215fbc88-07e7-46f9-828a-a0347ec1503c/wallets'
          result[0][:request_body] = {
            "body": {
              "data": {
                "wallets": [
                  {
                    "address": '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt',
                    "name": 'Wallet'
                  }
                ]
              },
              "url": 'http://example.org/api/v1/accounts/215fbc88-07e7-46f9-828a-a0347ec1503c/wallets',
              "method": 'POST',
              "nonce": '6121198620e6e2ea36b8cc13322b1f63',
              "timestamp": '1617707668'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": '2jQnVtGSK7ujKWSi8K5H8ax2Xn00TU6sffST8qECUVX7SanUndlsIh6Vd0OOeqXnAQF8QeKp7GtN8e8bM9f2Bw=='
            }
          }
        end
        expect(status).to eq(400)
        expect(response_body).to eq '{"errors":{"0":{"blockchain":["unknown blockchain value"]}}}'
      end
    end
  end

  put '/api/v1/accounts/:id/wallets/:wallet_id' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :wallet_id, 'wallet id', required: true, type: :string
    end

    with_options with_example: true do
      parameter :primary_wallet, 'primary wallet flag', required: false, type: :boolean
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:wallet_id) { create(:wallet, account: account).id.to_s }
      let(:update_params) { { wallet: { primary_wallet: true } } }

      example 'UPDATE WALLET' do
        explanation 'Returns updated wallet (See INDEX for response details)'

        request = build(:api_signed_request, update_params, api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'PUT', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/99905689-2789-4916-822b-6935829d89be/wallets/26'
          result[0][:request_body] = {
            "body": {
              "data": {
                "wallet": {
                  "primary_wallet": true
                }
              },
              "url": 'http://example.org/api/v1/accounts/99905689-2789-4916-822b-6935829d89be/wallets/26',
              "method": 'PUT',
              "nonce": 'ac5abe2f13fa3deb543462cf0d3a5767',
              "timestamp": '1617707672'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'BTZTkFckvtiv6vb2W5qrZHG8hts/Mwr0AkEHTbE/V55NoDDhQVPhuAVYCLsuh1AnBW+CzxDeSJ8MqY4hjFPvCQ=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"00a7de496cda43cf8d65ae75abbe3ce7"'
          result[0][:response_body] = {
            "id": 26,
            "name": 'Wallet',
            "address": '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt',
            "primaryWallet": true,
            "source": 'user_provided',
            "state": 'ok',
            "createdAt": '2021-04-06T11:14:32.514Z',
            "updatedAt": '2021-04-06T11:14:32.514Z',
            "blockchain": 'bitcoin',
            "provisionTokens": []
          }
        end
        expect(status).to eq(200)
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

      example 'GET WALLET' do
        explanation 'Returns specified wallet (See INDEX for response details)'

        request = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/a2a4d648-f184-4a14-90e5-f3eda18abfb5/wallets/22?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Faccounts%2Fa2a4d648-f184-4a14-90e5-f3eda18abfb5%2Fwallets%2F22&body[method]=GET&body[nonce]=eb20591fd286f1ccb1ebd240e53591f9&body[timestamp]=1617707670&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=t%2ByTuo494IgD%2F7E%2Bh3OoKTrqrOT%2FDJy5aHbtMWPROHqsdN0o9KFDe445GXRB%2BwynuwyDXIsNaN3vzoz6nU9dDA%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/accounts/a2a4d648-f184-4a14-90e5-f3eda18abfb5/wallets/22', 'method' => 'GET', 'nonce' => 'eb20591fd286f1ccb1ebd240e53591f9', 'timestamp' => '1617707670' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 't+yTuo494IgD/7E+h3OoKTrqrOT/DJy5aHbtMWPROHqsdN0o9KFDe445GXRB+wynuwyDXIsNaN3vzoz6nU9dDA==' } }
          result[0][:response_headers]['ETag'] = 'W/"858c0b3eba44ad8a2e5e38329ad310b5"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 11:14:30 GMT'
          result[0][:response_body] = {
            "id": 22,
            "name": 'Wallet',
            "address": '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt',
            "primaryWallet": true,
            "source": 'user_provided',
            "state": 'ok',
            "createdAt": '2021-04-06T11:14:30.633Z',
            "updatedAt": '2021-04-06T11:14:30.633Z',
            "blockchain": 'bitcoin',
            "provisionTokens": []
          }
        end
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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/ae277852-b899-49c0-983a-3c9fc3cfb2f5/wallets/23'
          result[0][:request_body] = {
            "body": {
              "data": '',
              "url": 'http://example.org/api/v1/accounts/ae277852-b899-49c0-983a-3c9fc3cfb2f5/wallets/23',
              "method": 'DELETE',
              "nonce": 'e39deea5b41d927fab893ff67859bd8f',
              "timestamp": '1617707671'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'V+VLVJBe31B0c0TDnfuN/KNyslfgQOMBTIZUcsMPN6xB1i4Mx9O52vkkZ/bj7pDABpYRgxs6x4Qi86FrEWNqBA=='
            }
          }
          result[0][:response_headers]['ETag'] = 'ETag: W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"'
        end
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
      let!(:wallet_id) { create(:ore_id_wallet, account: account).id.to_s }
      let!(:redirect_url) { 'localhost' }

      example 'GET RESET PASSWORD URL (ONLY ORE_ID WALLETS)' do
        explanation 'Returns reset password url for wallet'

        request = build(:api_signed_request, { redirect_url: redirect_url }, password_reset_api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'POST', 'example.org')

        allow_any_instance_of(OreIdService).to receive(:create_token).and_return('dummy_token')
        allow_any_instance_of(OreIdService).to receive(:remote).and_return({ 'email' => account.email })
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/526426da-f154-4cb2-a62b-b7272edf4522/wallets/25/password_reset'
          result[0][:request_body] = {
            "redirect_url": 'localhost',
            "body": {
              "data": {
                "redirect_url": 'localhost'
              },
              "url": 'http://example.org/api/v1/accounts/526426da-f154-4cb2-a62b-b7272edf4522/wallets/25/password_reset',
              "method": 'POST',
              "nonce": '294fc1198629f41922451f153b3094c0',
              "timestamp": '1617707671'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": '+VItidF1V6F1O4/THri0HlXczRThTB0KGYHeUUqauBw6UrGKdNbLha958eRWjblPqIpbVz0jF/6fwMKsCMUhDg=='
            }
          }

          result[0][:response_headers]['ETag'] = 'W/"98478faf3abecd5323605bf65c68c306"'
          result[0][:response_body] = { "resetUrl": 'https://service.oreid.io/recover-account?account=&app_access_token=dummy_token&background_color=FFFFFF&callback_url=localhost&email=me%2B8e34c3b89ce220648a3a371617b005c518d3d97a%40example.com&provider=email&recover_action=republic&state=&hmac=FHcIdy4r%2Fb6NGoEKZy18G0CkzI7Y2JksskpX8JVNp9w%3D' }
        end
        expect(status).to eq(200)
      end
    end
  end
end
