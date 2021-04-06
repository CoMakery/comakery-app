require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'IV. Transfers' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:token, decimal_places: 8, _blockchain: :ethereum)) }
  let!(:transfer_accepted) { create(:transfer, description: 'Award to a team member', amount: 1000, quantity: 2, award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }
  let!(:transfer_paid) { create(:transfer, status: :paid, ethereum_transaction_address: '0x7709dbc577122d8db3522872944cefcb97408d5f74105a1fbb1fd3fb51cc496c', award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }
  let!(:transfer_cancelled) { create(:transfer, status: :cancelled, transaction_error: 'MetaMask Tx Signature: User denied transaction signature.', award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }

  explanation 'Create and cancel transfers, retrieve transfer data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/projects/:project_id/transfers' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of transfers. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_transfers_path(project_id: project.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/6/transfers?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects%2F6%2Ftransfers&body[method]=GET&body[nonce]=2983fec178d51a37fc9b7f7b7e023304&body[timestamp]=1617691461&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=TYtn5zmLPtSQp33BJfqtPFZDRINYgRspNhgfLzdpXPQT2HEsiDM5rtkyaX7PJe4rHOBQYko2FTW70hgmY1O0Cg%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: { 'data' => '', 'url' => 'http://example.org/api/v1/projects/6/transfers', 'method' => 'GET', 'nonce' => '2983fec178d51a37fc9b7f7b7e023304', 'timestamp' => '1617691461' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'TYtn5zmLPtSQp33BJfqtPFZDRINYgRspNhgfLzdpXPQT2HEsiDM5rtkyaX7PJe4rHOBQYko2FTW70hgmY1O0Cg==' } }
          result[0][:response_headers]['ETag'] = 'W/"9126d4e814c305073ccd49080da2a3c8"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 06:44:21 GMT'
          result[0][:response_body] = [
            {
              "id": 19,
              "transferTypeId": 31,
              "recipientWalletId": nil,
              "amount": '50.0',
              "quantity": '1.0',
              "totalAmount": '50.0',
              "description": 'Investment',
              "transactionError": 'MetaMask Tx Signature: User denied transaction signature.',
              "status": 'cancelled',
              "createdAt": '2021-04-06T06:44:21.271Z',
              "updatedAt": '2021-04-06T06:44:21.271Z',
              "accountId": '885fca1d-b115-4cc8-a053-b96a005d2b4c',
              "projectId": 6
            },
            {
              "id": 18,
              "transferTypeId": 30,
              "recipientWalletId": nil,
              "amount": '50.0',
              "quantity": '1.0',
              "totalAmount": '50.0',
              "description": 'Investment',
              "transactionError": nil,
              "status": 'paid',
              "createdAt": '2021-04-06T06:44:21.171Z',
              "updatedAt": '2021-04-06T06:44:21.163Z',
              "accountId": '1e2a623b-9407-4db3-98ac-c0ad8b7068e0',
              "projectId": 6
            },
            {
              "id": 17,
              "transferTypeId": 29,
              "recipientWalletId": nil,
              "amount": '1000.0',
              "quantity": '2.0',
              "totalAmount": '2000.0',
              "description": 'Award to a team member',
              "transactionError": nil,
              "status": 'accepted',
              "createdAt": '2021-04-06T06:44:21.055Z',
              "updatedAt": '2021-04-06T06:44:21.055Z',
              "accountId": '72ffaf5d-1a1b-4ab7-ac19-92fb2b9ab133',
              "projectId": 6
            }
          ]

        end
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:project_id/transfers/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'transfer id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'transfer id', type: :integer
      response_field :amount, 'transfer amount', type: :string
      response_field :quantity, 'transfer quantity', type: :string
      response_field :totalAmount, 'transfer total amount', type: :string
      response_field :description, 'transfer description', type: :string
      response_field :accountId, 'transfer account id', type: :string
      response_field :transferTypeId, 'category id', type: :string
      response_field :transactionError, 'latest recieved transaction error (returned from DApp on unsuccessful transaction)', type: :string
      response_field :status, 'transfer status (accepted paid cancelled)', type: :string
      response_field :recipientWalletId, 'recipient wallet id', type: :string
      response_field :createdAt, 'transfer creation timestamp', type: :string
      response_field :updatedAt, 'transfer update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { transfer_paid.id }

      example 'GET' do
        explanation 'Returns data for a single transfer.'

        request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_paid.id, project_id: project.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/5/transfers/15?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects%2F5%2Ftransfers%2F15&body[method]=GET&body[nonce]=9bc9942b2232e055e35bbd9a9231a48b&body[timestamp]=1617691460&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=zemiZzEyx2Wc7rHSUB4gIDuJ5mnpU%2BY%2FF1qfrB7gm6ibmeaWXpGxzaOQzn1FXOnfxKFh5be81X8yS2MSJUuJAw%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/projects/5/transfers/15', 'method' => 'GET', 'nonce' => '9bc9942b2232e055e35bbd9a9231a48b', 'timestamp' => '1617691460' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'zemiZzEyx2Wc7rHSUB4gIDuJ5mnpU+Y/F1qfrB7gm6ibmeaWXpGxzaOQzn1FXOnfxKFh5be81X8yS2MSJUuJAw==' } }
          result[0][:response_headers]['ETag'] = 'W/"5e24606865078a3ade08501003dc5ccf"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 06:44:19 GMT'
          result[0][:response_body] = {
            "id": 15,
            "transferTypeId": 25,
            "recipientWalletId": nil,
            "amount": '50.0',
            "quantity": '1.0',
            "totalAmount": '50.0',
            "description": 'Investment',
            "transactionError": nil,
            "status": 'paid',
            "createdAt": '2021-04-06T06:44:19.967Z',
            "updatedAt": '2021-04-06T06:44:19.959Z',
            "accountId": '54249a31-2154-4427-80b9-3ecd617e0b8d',
            "projectId": 5
          }
        end
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/transfers' do
    let(:account) { create(:account, managed_mission: active_whitelabel_mission) }
    let!(:wallet) { create(:wallet, account: account, _blockchain: project.token._blockchain, address: build(:ethereum_address_1)) }

    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :transfer, with_example: true do
      parameter :amount, 'transfer amount (same decimals as token)', required: true, type: :string
      parameter :quantity, 'transfer quantity (2 decimals)', required: true, type: :string
      parameter :total_amount, 'transfer total_amount (amount times quantity, same decimals as token)', required: true, type: :string
      parameter :account_id, 'transfer account id', required: true, type: :string
      parameter :transfer_type_id, 'custom transfer type id (default: earned)', required: false, type: :string
      parameter :recipient_wallet_id, 'custom recipient wallet id', required: false, type: :string
      parameter :description, 'transfer description', type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:transfer) do
        {
          amount: '1000.00000000',
          quantity: '2.00',
          total_amount: '2000.00000000',
          description: 'investor',
          transfer_type_id: create(:transfer_type, project: project).id.to_s,
          account_id: account.managed_account_id.to_s,
          recipient_wallet_id: wallet.id.to_s
        }
      end

      example 'CREATE' do
        explanation 'Returns created transfer details (See GET for response details)'

        request = build(:api_signed_request, { transfer: transfer }, api_v1_project_transfers_path(project_id: project.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/projects/4/transfers'
          result[0][:request_body] = {
            "body": {
              "data": {
                "transfer": {
                  "amount": '1000.00000000',
                  "quantity": '2.00',
                  "total_amount": '2000.00000000',
                  "description": 'investor',
                  "transfer_type_id": '21',
                  "account_id": '1e0d0e31-ec5f-4aaa-afb7-59e93bd5c387',
                  "recipient_wallet_id": '2'
                }
              },
              "url": 'http://example.org/api/v1/projects/4/transfers',
              "method": 'POST',
              "nonce": 'c15c604d79cc1f678adebf79166f9785',
              "timestamp": '1617691458'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'ryoVuiFiYKVyupP1fXjvfQe5e5CL+h3BQCwtl833oyE35iN1E3JOn+NrsZFcdHF9b6gvRAuQd5raBFx9Xr/OBA=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"076fd28b3a69c620a38916045a97c3e5"'
          result[0][:response_body] = {
            "id": 13,
            "transferTypeId": 21,
            "recipientWalletId": 2,
            "amount": '1000.0',
            "quantity": '2.0',
            "totalAmount": '2000.0',
            "description": 'investor',
            "transactionError": nil,
            "status": 'accepted',
            "createdAt": '2021-04-06T06:44:18.916Z',
            "updatedAt": '2021-04-06T06:44:18.916Z',
            "accountId": '1e0d0e31-ec5f-4aaa-afb7-59e93bd5c387',
            "projectId": 4
          }
        end
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:transfer) do
        {
          amount: '-1.00',
          account_id: create(:account, managed_mission: active_whitelabel_mission).managed_account_id.to_s
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { transfer: transfer }, api_v1_project_transfers_path(project_id: project.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/projects/3/transfers'
          result[0][:request_body] = {
            "body": {
              "data": {
                "transfer": {
                  "amount": '-1.00',
                  "account_id": 'e56c2edb-2864-413d-97ea-0e6578964b23'
                }
              },
              "url": 'http://example.org/api/v1/projects/3/transfers',
              "method": 'POST',
              "nonce": '37d0b42deb1e7a977e60948dc40059d4',
              "timestamp": '1617691457'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": '+I9g0PTijLeUuOJiQkDT1mIFdsBoJCM61afk7U0OaUkTDTrPejTgKmwTeobb4Tys0aTbG326Hs/cekL8cV/sCw=='
            }
          }
        end
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/transfers/:id' do
    with_options with_example: true do
      parameter :id, 'transfer id', required: true, type: :integer
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '200' do
      let!(:id) { transfer_accepted.id }
      let!(:project_id) { project.id }

      example 'CANCEL' do
        explanation 'Returns cancelled transfer details (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_accepted.id, project_id: project.id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/1/transfers/1'
          result[0][:request_body] = {
            "body": {
              "data": '',
              "url": 'http://example.org/api/v1/projects/1/transfers/1',
              "method": 'DELETE',
              "nonce": '5a43d9c20f91d44e069e3000f1061b8e',
              "timestamp": '1617691454'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'u5aGleOl6D/vt+9BwLCGEMYDxDcxdEbJ0BImUtQBK0aFjFXNAcuDUjof/JPQrFLtdUgpzmmQDXYGfpOp+QB4BQ=='
            }
          }
          result[0][:response_headers]['ETag'] = 'W/"4678832305e19ebb7d254e64503c7b0c"'
          result[0][:response_body] = {
            "id": 1,
            "transferTypeId": 3,
            "recipientWalletId": nil,
            "amount": '1000.0',
            "quantity": '2.0',
            "totalAmount": '2000.0',
            "description": 'Award to a team member',
            "transactionError": nil,
            "status": 'cancelled',
            "createdAt": '2021-04-06T06:44:14.344Z',
            "updatedAt": '2021-04-06T06:44:14.895Z',
            "accountId": 'f6b73fd1-c049-4ba3-8307-b538c13d7200',
            "projectId": 1
          }
        end
        expect(status).to eq(200)
      end
    end

    context '400' do
      let!(:id) { transfer_paid.id }
      let!(:project_id) { project.id }

      example 'CANCEL – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_paid.id, project_id: project.id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/projects/2/transfers/5'
          result[0][:request_body] = {
            "body": {
              "data": '',
              "url": 'http://example.org/api/v1/projects/2/transfers/5',
              "method": 'DELETE',
              "nonce": '382721e66f932d0fe885e709e22aa13e',
              "timestamp": '1617691456'
            },
            "proof": {
              "type": 'Ed25519Signature2018',
              "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
              "signature": 'qsqHhjQQxXW0yXp2m1d0zhhduIO+gHsZrJyuybHcra+i+lulyy5DRdJIPThVpF0VrUOihnspITxejFFL3HguCQ=='
            }
          }

        end
        expect(status).to eq(400)
      end
    end
  end
end
