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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/1c182a7b-4f22-4636-9047-8bab32352949?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Faccounts%2F1c182a7b-4f22-4636-9047-8bab32352949&body[method]=GET&body[nonce]=32a3d4dd9e4dfc030700f455587a2df9&body[timestamp]=1617683146&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=GJrHY52pTf2vUChqNDsOcGcYXkCx8p2IEDM9zAZ2axi4RlT3S%2F5Zm6y%2FWeyTbBk6%2Fk4Om5SVSyNSKz4ve%2FvBDw%3D%3D'

          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/accounts/1c182a7b-4f22-4636-9047-8bab32352949', 'method' => 'GET', 'nonce' => '32a3d4dd9e4dfc030700f455587a2df9', 'timestamp' => '1617683146' }, proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'GJrHY52pTf2vUChqNDsOcGcYXkCx8p2IEDM9zAZ2axi4RlT3S/5Zm6y/WeyTbBk6/k4Om5SVSyNSKz4ve/vBDw==' } }
          result[0][:response_headers]['ETag'] = 'W/"aecd4c102563a30e2b5681b9d901989d"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 04:25:45 GMT'
          result[0][:response_body] = {
            "email": 'me+cc4b6d000417106d1cbbb357ebadd3a0560718bb@example.com',
            "managedAccountId": '1c182a7b-4f22-4636-9047-8bab32352949',
            "firstName": 'Eva',
            "lastName": 'Smith',
            "nickname": 'hunter-0cc45156d229f0a44c938ae649dedb8c1e0ca1de',
            "imageUrl": 'http://example.org/assets/default_account_image-eee1531b23fb9820d114c626a7e4212a9c54f7cf8522720d6ba1454787299a53.jpg',
            "country": 'United States of America',
            "dateOfBirth": '1990-01-01',
            "verificationState": 'passed',
            "verificationDate": '2021-04-06T04:25:45.842Z',
            "verificationMaxInvestmentUsd": 1000000,
            "createdAt": '2021-04-06T04:25:45.808Z',
            "updatedAt": '2021-04-06T04:25:45.854Z'
          }
        end
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
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '201' do
      let!(:account_params) do
        {
          managed_account_id: SecureRandom.uuid,
          email: "me+#{SecureRandom.hex(20)}@example.com",
          first_name: 'Eva',
          last_name: 'Smith',
          nickname: "hunter-#{SecureRandom.hex(20)}",
          date_of_birth: '1990-01-31',
          country: 'United States of America'
        }
      end

      example 'CREATE' do
        explanation 'Returns created account data (See GET for response details)'

        request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_body] = {
            "body": {
              "data": {
                "account": {
                  "managed_account_id": '1eeb143f-f0c3-4e85-b66e-92c39edcdef5',
                  "email": 'me+ca63bd484da019f1938825ffcba6dab25376c25a@example.com',
                  "first_name": 'Eva',
                  "last_name": 'Smith',
                  "nickname": 'hunter-b1f157fc0d5ec93680d7b307d417bc5bd2c04e00',
                  "date_of_birth": '1990-01-31',
                  "country": 'United States of America'
                }
              },
              "url": 'http://example.org/api/v1/accounts',
              "method": 'POST',
              "nonce": 'd7266d55870a31022b63c310387388f3',
              "timestamp": '1617683160'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": '39blSiLwyfAH9NbgRrISKRpjim9yu13qAdqcH/dwiFwqEXUdOCxG5aowQFbN8QbZMyHRexghs4XGOAj3NveMDg=='
            }
          }
          result[0][:response_headers]['ETag'] = 'ETag: W/"05eed70390aba0239d05b63b1b6e3a53"'
          result[0][:response_body] = {
            "email": 'me+ca63bd484da019f1938825ffcba6dab25376c25a@example.com',
            "managedAccountId": '1eeb143f-f0c3-4e85-b66e-92c39edcdef5',
            "firstName": 'Eva',
            "lastName": 'Smith',
            "nickname": 'hunter-b1f157fc0d5ec93680d7b307d417bc5bd2c04e00',
            "imageUrl": 'http://example.org/assets/default_account_image-eee1531b23fb9820d114c626a7e4212a9c54f7cf8522720d6ba1454787299a53.jpg',
            "country": 'United States of America',
            "dateOfBirth": '1990-01-31',
            "verificationState": 'unknown',
            "verificationDate": nil,
            "verificationMaxInvestmentUsd": nil,
            "createdAt": '2021-04-06T04:26:00.733Z',
            "updatedAt": '2021-04-06T04:26:00.733Z'
          }
        end
        expect(status).to eq(201)
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
        result = do_request(request)
        if status == 400
          result[0][:request_body] = {
            "body": {
              "data": {
                "account": {
                  "managed_account_id": '37edfd11-6554-4a0c-b104-1a123aa62de1'
                }
              },
              "url": 'http://example.org/api/v1/accounts',
              "method": 'POST',
              "nonce": '130b25e75d511ab5ce8ee4844d9fece6',
              "timestamp": '1617683161'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'ZPMfn1YSra5JN2LrC4aKUFSUo1VfzeJFmYBP0XcOV7I8mz5PEwDmGHo4j57RPuPBlCMNlwNmagS1ePI8PAUXCA=='
            }
          }
          result[0][:response_body] = {
            "errors": {
              "email": [
                "can't be blank"
              ],
              "firstName": [
                "can't be blank"
              ],
              "lastName": [
                "can't be blank"
              ],
              "country": [
                "can't be blank"
              ],
              "dateOfBirth": [
                'should be present in correct format'
              ]
            }
          }
        end
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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/94d3762e-f0bd-4199-97f6-e1d74406d2bd'
          result[0][:request_body] = {
            "body": {
              "data": {
                "account": {
                  "first_name": 'Alex'
                }
              },
              "url": 'http://example.org/api/v1/accounts/94d3762e-f0bd-4199-97f6-e1d74406d2bd',
              "method": 'PUT',
              "nonce": '947d2cdd0bf16037910798baeca6aad7',
              "timestamp": '1617683157'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'eykYt2SAKSZB9dFOUW3LrpcYxitq8gSMXNXkWzUW1bS3NjkZwh2+OeYg3TKLYD7LGu5dU9iTAo3W8Xe5oXBoAg=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"d75df5569b8616604e8cd6733bcd9964"'
          result[0][:response_body] = {
            "email": 'me+0a3bc6299610167ad0825c865e4c012b0864f6ec@example.com',
            "managedAccountId": '94d3762e-f0bd-4199-97f6-e1d74406d2bd',
            "firstName": 'Alex',
            "lastName": 'Smith',
            "nickname": 'hunter-bd60fa8400789aad9fdb455ce8d40e5768797a79',
            "imageUrl": 'http://example.org/assets/default_account_image-eee1531b23fb9820d114c626a7e4212a9c54f7cf8522720d6ba1454787299a53.jpg',
            "country": 'United States of America',
            "dateOfBirth": '1990-01-01',
            "verificationState": 'unknown',
            "verificationDate": nil,
            "verificationMaxInvestmentUsd": nil,
            "createdAt": '2021-04-06T04:25:56.689Z',
            "updatedAt": '2021-04-06T04:25:57.856Z'
          }

        end
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
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/accounts/04edfe2d-1bab-4b01-b34d-c4fff244c0ba'
          result[0][:request_body] = {
            "body": {
              "data": {
                "account": {
                  "email": '0x'
                }
              },
              "url": 'http://example.org/api/v1/accounts/04edfe2d-1bab-4b01-b34d-c4fff244c0ba',
              "method": 'PUT',
              "nonce": 'dc596324769749e2fd7b9577e27514b9',
              "timestamp": '1617683156'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'OvdC7pMlFjEgcIY632PEK12wd9VSBoxdPp6xxRpSI0XpB7/Qk89d1cvqOZDJ3beADCxVNIBLWwfAzq9GvjlnBA=='
            }
          }

        end
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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/06620cee-a333-4a39-94e5-08450237e0ab/interests?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Faccounts%2F06620cee-a333-4a39-94e5-08450237e0ab%2Finterests&body[method]=GET&body[nonce]=92ba07961f80f948addd84bb2b71d8b2&body[timestamp]=1617683166&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=5mPDauLYIcMjLKRPhp3sEpZi8rpQ91XhLulYrGCwMQpfflTLB0kBgI2LsRriRBo4uxiBcg9p9q1BCEf7QguVCA%3D%3D'

          result[0][:request_query_parameters] = { page: 1, body: { 'data' => '', 'url' => 'http://example.org/api/v1/accounts/06620cee-a333-4a39-94e5-08450237e0ab/interests', 'method' => 'GET', 'nonce' => '92ba07961f80f948addd84bb2b71d8b2', 'timestamp' => '1617683166' }, proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => '5mPDauLYIcMjLKRPhp3sEpZi8rpQ91XhLulYrGCwMQpfflTLB0kBgI2LsRriRBo4uxiBcg9p9q1BCEf7QguVCA==' } }

          result[0][:response_headers]['ETag'] = 'W/"72fab65dcba8eb739ffc2c358b3c2e8b"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 04:26:06 GMT'
          result[0][:response_body] = [27, 26]

        end
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

    context '201' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      example 'CREATE INTEREST' do
        explanation 'Returns account interests (See INTERESTS for response details)'

        request = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_interests_path(account_id: account.managed_account_id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/accounts/a8325243-a892-451f-947e-fdf867f6b3c7/interests'
          result[0][:request_body] = {
            "project_id": 30,
            "body": {
              "data": {
                "project_id": '30'
              },
              "url": 'http://example.org/api/v1/accounts/a8325243-a892-451f-947e-fdf867f6b3c7/interests',
              "method": 'POST',
              "nonce": 'b0b408b5c3c9eceb99352e94cfa7c379',
              "timestamp": '1617683169'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'cY9p9P0UVhbxEGNjIkZUpVlJ6FcUWMzQ13zJQPiKM1Zg1sq2AvMdlM/1ex94SYLVmyUvZkDjD/DA8Z5wLaNiDA=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"5436cc4750cf070868dc8194674f290f"'
          result[0][:response_body] = [30]

        end
        expect(status).to eq(201)
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
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/accounts/b0b3946c-1581-4136-bada-edb5f937219b/interests'
          result[0][:request_body] = {
            "project_id": 28,
            "body": {
              "data": {
                "project_id": '28'
              },
              "url": 'http://example.org/api/v1/accounts/b0b3946c-1581-4136-bada-edb5f937219b/interests',
              "method": 'POST',
              "nonce": 'd931cc2e547207a221136123dc3a0a3f',
              "timestamp": '1617683167'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'oZbZmEdY3JZUITI6RFvr2CySjE6me7/3JspmYuDdHXUVz59Yz+YlMGe8+nntR9Nap86bzBoFuu5kO3L5N/K+Aw=='
            }
          }
        end
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/accounts/:id/interests/:project_id' do
    with_options with_example: true do
      parameter :id, 'account id', required: true, type: :string
      parameter :project_id, 'project id to uninterest', required: true, type: :string
    end

    context '200' do
      let!(:id) { account.managed_account_id }
      let!(:project_id) { project.id }

      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      example 'REMOVE INTEREST' do
        explanation 'Returns account interests (See INTERESTS for response details)'

        request = build(:api_signed_request, '', api_v1_account_interest_path(account_id: account.managed_account_id, id: project.id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/adedf9c6-f8f6-4820-bba2-1104cc8cbb50/interests/16'
          result[0][:request_body] = {
            "body": {
              "data": '',
              "url": 'http://example.org/api/v1/accounts/adedf9c6-f8f6-4820-bba2-1104cc8cbb50/interests/16',
              "method": 'DELETE',
              "nonce": '253f2fa40ee903100971c9ee79d08b5f',
              "timestamp": '1617683159'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": '0F2yiEluLXe9QTFmuJRoFw7waiXSvsDiY05ytvqnNZT+VMwgsSZurk0qRgin3BpluqyaB84TLf8CSdVuDtTEBg=='
            }
          }

          result[0][:response_headers]['ETag'] = 'W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"'
        end
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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/defad8b1-2927-4f6d-b68c-7e6045092104/verifications?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Faccounts%2Fdefad8b1-2927-4f6d-b68c-7e6045092104%2Fverifications&body[method]=GET&body[nonce]=72dc9960cf2dd6a06cef33bd7a91bd0e&body[timestamp]=1617683140&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=12JUbOLs%2BPzYxsJesQfIcaJRlvSNuxmcOcfwKQ%2Bz%2FZjUneLjkgXDQdQM8d0p2eZD4Fi%2B%2BYzC9LNH7X2Q9V%2BHAw%3D%3D'
          result[0][:request_query_parameters] = { page: 1, body: { 'data' => '', 'url' => 'http://example.org/api/v1/accounts/defad8b1-2927-4f6d-b68c-7e6045092104/verifications', 'method' => 'GET', 'nonce' => '72dc9960cf2dd6a06cef33bd7a91bd0e', 'timestamp' => '1617683140' }, proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => '12JUbOLs+PzYxsJesQfIcaJRlvSNuxmcOcfwKQ+z/ZjUneLjkgXDQdQM8d0p2eZD4Fi++YzC9LNH7X2Q9V+HAw==' } }

          result[0][:response_headers]['ETag'] = 'W/"2d6adcc10df36bd6dd2a03028f1401ec"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 04:25:40 GMT'
          result[0][:response_body] = [
            {
              "passed": true,
              "verificationType": 'aml-kyc',
              "maxInvestmentUsd": 1000000,
              "createdAt": '2021-04-06T04:25:38.633Z',
              "updatedAt": '2021-04-06T04:25:38.633Z'
            },
            {
              "passed": false,
              "verificationType": 'aml-kyc',
              "maxInvestmentUsd": 100000,
              "createdAt": '2021-04-06T04:25:39.988Z',
              "updatedAt": '2021-04-06T04:25:39.988Z'
            },
            {
              "passed": true,
              "verificationType": 'aml-kyc',
              "maxInvestmentUsd": 10000,
              "createdAt": '2021-04-06T04:25:40.004Z',
              "updatedAt": '2021-04-06T04:25:40.004Z'
            }
          ]
        end
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
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/accounts/9f392236-2175-485b-b6f1-810a8cc7675c/verifications'
          result[0][:request_body] = {
            "body": {
              "data": {
                "verification": {
                  "passed": 'true',
                  "max_investment_usd": '10000',
                  "verification_type": 'aml-kyc',
                  "created_at": '2021-04-03 04:25:42 UTC'
                }
              },
              "url": 'http://example.org/api/v1/accounts/9f392236-2175-485b-b6f1-810a8cc7675c/verifications',
              "method": 'POST',
              "nonce": 'f95488b19858bd2a6ea7b9198c13d9a2',
              "timestamp": '1617683143'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'cNdYy3M44Y7DVq0kuWbMbSefwR4osACE5K8f+5h7CffvO8iGeS326i4CBUzKyUReb5Ckj1gb8xosSZfZTcHyDg=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"f621f10df12d99b826fe62e9a64acc48"'
          result[0][:response_body] = [
            {
              "passed": true,
              "verificationType": 'aml-kyc',
              "maxInvestmentUsd": 10000,
              "createdAt": '2021-04-03T04:25:42.000Z',
              "updatedAt": '2021-04-06T04:25:43.302Z'
            }
          ]

        end
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
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/accounts/441dc8e1-2aaf-4eaa-9a5f-6cf9d1fa6daf/verifications'
          result[0][:request_body] = {
            "body": {
              "data": {
                "verification": {
                  "max_investment_usd": '0'
                }
              },
              "url": 'http://example.org/api/v1/accounts/441dc8e1-2aaf-4eaa-9a5f-6cf9d1fa6daf/verifications',
              "method": 'POST',
              "nonce": '1c1ce6c87fa0afe53c799ff66fb62002',
              "timestamp": '1617683141'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": '6a2jlSwlJJpBZxyiAmme8x+80c8he8PVvJ3L0TU5niYpDmMM5D1t5RCuXf4jNqwZw+eawFBFAZxU7nAIg0A6AA=='
            }
          }

        end
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
      let!(:token) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
      let!(:token2) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
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
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/6ac9fa6b-53e7-487c-bdef-ddb16ad2ed92/token_balances?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Faccounts%2F6ac9fa6b-53e7-487c-bdef-ddb16ad2ed92%2Ftoken_balances&body[method]=GET&body[nonce]=32d170482829c5857795ebddb22b282f&body[timestamp]=1617683164&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=7H6G1ufT2ozR8T%2FiHx%2BfTNyWIepexxAxhmRoTcAuTGSEIIPiHnOKhi0a9jFf9kTmqZLTa69XJfzI7HTdPgQ9AQ%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/accounts/6ac9fa6b-53e7-487c-bdef-ddb16ad2ed92/token_balances', 'method' => 'GET', 'nonce' => '32d170482829c5857795ebddb22b282f', 'timestamp' => '1617683164' }, proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => '7H6G1ufT2ozR8T/iHx+fTNyWIepexxAxhmRoTcAuTGSEIIPiHnOKhi0a9jFf9kTmqZLTa69XJfzI7HTdPgQ9AQ==' } }
          result[0][:response_headers]['ETag'] = 'W/"5ea9d4ad2331a15aa8203254304f5b6a"'
          result[0][:response_body] = [
            {
              "token": {
                "id": 24,
                "name": 'Token-1e7c322c102451dbfe57675d725bd4675f213a03',
                "symbol": 'TKNcd04b9ca324b33103940c88accb7faae986c51ab',
                "network": 'ethereum_ropsten',
                "contractAddress": '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
                "decimalPlaces": 0,
                "logoUrl": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBWW89IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--f721919fb6432fb34b7a3badd1a8d577c3cf5c81/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png',
                "createdAt": '2021-04-06T04:26:03.495Z',
                "updatedAt": '2021-04-06T04:26:04.886Z'
              },
              "blockchain": {
                "address": '0xB4252b39f8506A711205B0b1C4170f0034065b46',
                "balance": 200,
                "maxBalance": '100000',
                "lockupUntil": '2021-04-05T04:26:03.000Z',
                "accountFrozen": false
              },
              "totalReceived": '3.0',
              "totalReceivedAndAcceptedIn": '3.0'
            },
            {
              "token": {
                "id": 25,
                "name": 'Token-b1677736e2f9cf390bb77071f3080faa57f35d0f',
                "symbol": 'TKN572eed7bbbdc2e5f183b23cf6d5b0846bbaab9e1',
                "network": 'ethereum_ropsten',
                "contractAddress": '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
                "decimalPlaces": 0,
                "logoUrl": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBWXM9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--350226bf48046403d668a388d841d19bbedbd07c/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png',
                "createdAt": '2021-04-06T04:26:03.620Z',
                "updatedAt": '2021-04-06T04:26:04.958Z'
              },
              "blockchain": {
                "address": '0xB4252b39f8506A711205B0b1C4170f0034065b46',
                "balance": 200,
                "maxBalance": '100000',
                "lockupUntil": '2021-04-05T04:26:03.000Z',
                "accountFrozen": false
              },
              "totalReceived": '8.0',
              "totalReceivedAndAcceptedIn": '8.0'
            }
          ]
        end
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

      before do
        create(:award, account: account, status: :paid, amount: 1)
      end

      example 'TRANSFERS' do
        explanation 'Returns an array of transactions for the account'

        request = build(:api_signed_request, '', api_v1_account_transfers_path(account_id: account.managed_account_id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/accounts/a0f520a5-6fff-452c-a197-f70c9b8bef70/transfers?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Faccounts%2Fa0f520a5-6fff-452c-a197-f70c9b8bef70%2Ftransfers&body[method]=GET&body[nonce]=83d1a12b945fe10611f7da1b67d49291&body[timestamp]=1617683145&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=unl8w5mkiIKgWUd0Qn7QkT19%2FOBQquAvzdbvWGEzZNRLUg7w%2BAnDIOBFuXAn4p3KOkEAMz6ojSeUWeLIz9POBg%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: { 'data' => '', 'url' => 'http://example.org/api/v1/accounts/a0f520a5-6fff-452c-a197-f70c9b8bef70/transfers', 'method' => 'GET', 'nonce' => '83d1a12b945fe10611f7da1b67d49291', 'timestamp' => '1617683145' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'unl8w5mkiIKgWUd0Qn7QkT19/OBQquAvzdbvWGEzZNRLUg7w+AnDIOBFuXAn4p3KOkEAMz6ojSeUWeLIz9POBg==' } }

          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 04:25:45 GMT'
          result[0][:response_headers]['ETag'] = 'W/"992319ba356e52a114d5411e863388c9"'
          result[0][:response_body] = [
            {
              "id": 1,
              "transferTypeId": 19,
              "recipientWalletId": nil,
              "amount": '1.0',
              "quantity": '1.0',
              "totalAmount": '1.0',
              "description": 'none',
              "transactionError": nil,
              "status": 'paid',
              "createdAt": '2021-04-06T04:25:45.381Z',
              "updatedAt": '2021-04-06T04:25:45.359Z',
              "accountId": 'a0f520a5-6fff-452c-a197-f70c9b8bef70',
              "projectId": 9
            }
          ]
        end
        expect(status).to eq(200)
      end
    end
  end
end
