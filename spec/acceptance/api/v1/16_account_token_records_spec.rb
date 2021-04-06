require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'VI. Account Token Records' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account_token_record) { create(:account_token_record) }
  let!(:account) { account_token_record.account }
  let!(:token) { account_token_record.token }
  let!(:wallet) { account_token_record.wallet }

  explanation 'Create and delete account token records, retrieve account token record data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/tokens/:token_id/account_token_records' do
    with_options with_example: true do
      parameter :token_id, 'token id', required: true, type: :integer
      parameter :wallet_id, 'wallet id', required: false, type: :integer
      parameter :page, 'page number', type: :integer
    end

    with_options with_example: true do
      response_field :id, 'account token record id', type: :integer
      response_field :managed_account_id, 'account id', type: :integer
      response_field :wallet_id, 'wallet id', type: :integer
      response_field :token_id, 'token id', type: :integer
      response_field :reg_group_id, 'reg group id', type: :integer
      response_field :lockup_until, 'lockup until', type: :integer
      response_field :max_balance, 'max balance', type: :integer
      response_field :account_frozen, 'account frozen', type: :bool
      response_field :status, 'account token record status (created synced)', type: :string
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:token_id) { token.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of account token records. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/tokens/3/account_token_records?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens%2F3%2Faccount_token_records&body[method]=GET&body[nonce]=ea414404add277f50c73d893da442a37&body[timestamp]=1617700085&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=QB%2F%2FlHYBhsWTrikXatrKTHd3nNQxSTs7%2FjWhEzJBy9%2B%2BrSAN6DdUpqf1oTzl%2Fq83IBqgJMyxsbiyJcWgjpNxBw%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens/3/account_token_records", "method"=>"GET", "nonce"=>"ea414404add277f50c73d893da442a37", "timestamp"=>"1617700085"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"QB//lHYBhsWTrikXatrKTHd3nNQxSTs7/jWhEzJBy9++rSAN6DdUpqf1oTzl/q83IBqgJMyxsbiyJcWgjpNxBw=="}
                                                  }
          result[0][:response_headers]['ETag'] = 'W/"3cb591c9b891ba3883009cd97ef0f28b"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:05 GMT'
          result[0][:response_body] = [
                                        {
                                          "id": 3,
                                          "walletId": 3,
                                          "tokenId": 3,
                                          "maxBalance": 100000,
                                          "lockupUntil": "2021-04-05T09:08:05.000Z",
                                          "regGroupId": 6,
                                          "accountFrozen": false,
                                          "status": "created",
                                          "createdAt": "2021-04-06T09:08:05.502Z",
                                          "updatedAt": "2021-04-06T09:08:05.502Z",
                                          "managedAccountId": nil
                                        }
                                      ]
        end
        expect(status).to eq(200)
      end
    end

    context '200' do
      let!(:token_id) { token.id }
      let!(:wallet_id) { wallet.id }
      let!(:page) { 1 }

      example 'INDEX - FILTERED BY WALLET' do
        explanation 'Returns an array of account token records for the wallet. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id), 'GET', 'example.org')
        request[:wallet_id] = wallet_id

        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/tokens/2/account_token_records?wallet_id=2&page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens%2F2%2Faccount_token_records&body[method]=GET&body[nonce]=300cddff160a5747c65edae146b77b94&body[timestamp]=1617700084&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=wrCeUVfK8hjdMG32jXAJ186iShXi4T4f%2B0OUa1RznGtnsV3olrjLxldTCsSJVNA0910Y2c4b6OzxABXQsveiCg%3D%3D'
          result[0][:request_query_parameters] = { wallet_id: 2,
                                                   page: 1,
                                                   body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens/2/account_token_records", "method"=>"GET", "nonce"=>"300cddff160a5747c65edae146b77b94", "timestamp"=>"1617700084"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"wrCeUVfK8hjdMG32jXAJ186iShXi4T4f+0OUa1RznGtnsV3olrjLxldTCsSJVNA0910Y2c4b6OzxABXQsveiCg=="}
                                                }
          result[0][:response_headers]['ETag'] = 'W/"6c75622518f30478962f3a23fb4d9471"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:04 GMT'
          result[0][:response_body] = [
                                        {
                                          "id": 2,
                                          "walletId": 2,
                                          "tokenId": 2,
                                          "maxBalance": 100000,
                                          "lockupUntil": "2021-04-05T09:08:04.000Z",
                                          "regGroupId": 4,
                                          "accountFrozen": false,
                                          "status": "created",
                                          "createdAt": "2021-04-06T09:08:04.975Z",
                                          "updatedAt": "2021-04-06T09:08:04.975Z",
                                          "managedAccountId": nil
                                        }
                                      ]
          
        end
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/tokens/:token_id/account_token_records' do
    with_options with_example: true do
      parameter :token_id, 'token id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :account_token_record, with_example: true do
      parameter :max_balance, 'max balance', required: true, type: :string
      parameter :lockup_until, 'lockup until', required: true, type: :string
      parameter :reg_group_id, 'reg group id', required: true, type: :string
      parameter :managed_account_id, 'account id', required: true, type: :string
      parameter :wallet_id, 'wallet id (uses primary wallet by default)', required: false, type: :string
      parameter :account_frozen, 'frozen', required: true, type: :string
    end

    context '201' do
      let!(:token_id) { token.id }

      let!(:valid_attributes) do
        {
          max_balance: '100',
          lockup_until: '1',
          reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
          managed_account_id: create(:account, managed_account_id: 'new_managed_account').managed_account_id,
          account_frozen: 'false'
        }
      end

      example 'CREATE' do
        explanation 'Returns account token records details (See GET for response details)'

        request = build(:api_signed_request, { account_token_record: valid_attributes }, api_v1_token_account_token_records_path(token_id: token.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/tokens/4/account_token_records'
          result[0][:request_body] = {
                                        "body": {
                                          "data": {
                                            "account_token_record": {
                                              "max_balance": "100",
                                              "lockup_until": "1",
                                              "reg_group_id": "9",
                                              "managed_account_id": "new_managed_account",
                                              "account_frozen": "false"
                                            }
                                          },
                                          "url": "http://example.org/api/v1/tokens/4/account_token_records",
                                          "method": "POST",
                                          "nonce": "038f51a47e9abbb4d6377779d41c7211",
                                          "timestamp": "1617700086"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "BgFJh1yswKlXdXs8lZB7Yytetj7VgCQPtMzNwSFdang7zV7PtLVKVZs6ak2q0bzvNexjJg5fd0mrvjWTHo51BQ=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"165d52225419e10726d656a35cf32164"'
          result[0][:response_body] = [
                                        {
                                          "id": 4,
                                          "walletId": 4,
                                          "tokenId": 4,
                                          "maxBalance": 100000,
                                          "lockupUntil": "2021-04-05T09:08:06.000Z",
                                          "regGroupId": 8,
                                          "accountFrozen": false,
                                          "status": "created",
                                          "createdAt": "2021-04-06T09:08:06.366Z",
                                          "updatedAt": "2021-04-06T09:08:06.366Z",
                                          "managedAccountId": nil
                                        },
                                        {
                                          "id": 5,
                                          "walletId": nil,
                                          "tokenId": 4,
                                          "maxBalance": 100,
                                          "lockupUntil": "1970-01-01T00:00:01.000Z",
                                          "regGroupId": 9,
                                          "accountFrozen": false,
                                          "status": "created",
                                          "createdAt": "2021-04-06T09:08:06.463Z",
                                          "updatedAt": "2021-04-06T09:08:06.463Z",
                                          "managedAccountId": "new_managed_account"
                                        }
                                      ]                          
        end
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:token_id) { token.id }

      let!(:invalid_attributes) do
        {
          max_balance: '-100',
          lockup_until: '1',
          reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
          managed_account_id: create(:account, managed_account_id: 'new_managed_account').managed_account_id,
          account_frozen: 'false'
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { account_token_record: invalid_attributes }, api_v1_token_account_token_records_path(token_id: token.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/tokens/5/account_token_records'
          result[0][:request_body] = {
                                      "body": {
                                        "data": {
                                          "account_token_record": {
                                            "max_balance": "-100",
                                            "lockup_until": "1",
                                            "reg_group_id": "12",
                                            "managed_account_id": "new_managed_account",
                                            "account_frozen": "false"
                                          }
                                        },
                                        "url": "http://example.org/api/v1/tokens/5/account_token_records",
                                        "method": "POST",
                                        "nonce": "2c4812c22f155726787270047c16abdb",
                                        "timestamp": "1617700086"
                                      },
                                      "proof": {
                                        "type": "Ed25519Signature2018",
                                        "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                        "signature": "TKYr/ZzufZyhd/tS8K/+4Wr7EXsoWAOzZFH5ct+euCC2Nydq8Aq8jd1j9EPLCCBg9gk6LtCpd1zU+kD8W++8CQ=="
                                      }
                                    }
        end
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/tokens/:token_id/account_token_records/?wallet_id=:wallet_id' do
    with_options with_example: true do
      parameter :id, 'account token record id', required: true, type: :integer
      parameter :token_id, 'token id', required: true, type: :integer
      parameter :wallet_id, 'wallet id', required: true, type: :integer
    end

    context '200' do
      let!(:id) { account_token_record.id }
      let!(:token_id) { token.id }
      let!(:wallet_id) { wallet.id }

      example 'DELETE' do
        explanation 'Delete all account token records for the wallet and returns an array of present account token records (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id, wallet_id: wallet_id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/tokens/1/account_token_records/?wallet_id=1'
          result[0][:request_query_parameters] = {wallet_id: 1}
          result[0][:request_body] = {
                                        "id": 1,
                                        "body": {
                                          "data": "",
                                          "url": "http://example.org/api/v1/tokens/1/account_token_records?wallet_id=1",
                                          "method": "DELETE",
                                          "nonce": "ccbc5c96a8e7393b5ab8d25f86b13305",
                                          "timestamp": "1617700083"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "EdxcJfA4fHj0pyV3AM8/bJHyuaTqVrS4uEVXSAz26CjQozzBn7KP9YGwewVypf5I3gJqcYMPSajew5yoN45kCw=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"'
        end
        expect(status).to eq(200)
      end
    end
  end
end
