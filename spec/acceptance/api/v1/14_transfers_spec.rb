# require 'rails_helper'
# require 'rspec_api_documentation/dsl'

# resource 'IV. Transfers' do
#   include Rails.application.routes.url_helpers

#   let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
#   let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:token, decimal_places: 8, _blockchain: :ethereum)) }
#   let!(:transfer_accepted) { create(:transfer, description: 'Award to a team member', amount: 1000, quantity: 2, award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }
#   let!(:transfer_paid) { create(:transfer, status: :paid, ethereum_transaction_address: '0x7709dbc577122d8db3522872944cefcb97408d5f74105a1fbb1fd3fb51cc496c', award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }
#   let!(:transfer_cancelled) { create(:transfer, status: :cancelled, transaction_error: 'MetaMask Tx Signature: User denied transaction signature.', award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }

#   explanation 'Create and cancel transfers, retrieve transfer data.'

#   header 'API-Key', build(:api_key)
#   header 'Content-Type', 'application/json'

#   get '/api/v1/projects/:project_id/transfers' do
#     with_options with_example: true do
#       parameter :project_id, 'project id', required: true, type: :integer
#       parameter :page, 'page number', type: :integer
#     end

#     context '200' do
#       let!(:project_id) { project.id }
#       let!(:page) { 1 }

#       example 'INDEX' do
#         explanation 'Returns an array of transfers. See GET for response fields description.'

#         request = build(:api_signed_request, '', api_v1_project_transfers_path(project_id: project.id), 'GET', 'example.org')
#         result = do_request(request)
#         binding.pry
#         expect(status).to eq(200)
#       end
#     end
#   end

#   get '/api/v1/projects/:project_id/transfers/:id' do
#     with_options with_example: true do
#       parameter :project_id, 'project id', required: true, type: :integer
#       parameter :id, 'transfer id', required: true, type: :integer
#     end

#     with_options with_example: true do
#       response_field :id, 'transfer id', type: :integer
#       response_field :amount, 'transfer amount', type: :string
#       response_field :quantity, 'transfer quantity', type: :string
#       response_field :totalAmount, 'transfer total amount', type: :string
#       response_field :description, 'transfer description', type: :string
#       response_field :accountId, 'transfer account id', type: :string
#       response_field :transferTypeId, 'category id', type: :string
#       response_field :transactionError, 'latest recieved transaction error (returned from DApp on unsuccessful transaction)', type: :string
#       response_field :status, 'transfer status (accepted paid cancelled)', type: :string
#       response_field :recipientWalletId, 'recipient wallet id', type: :string
#       response_field :createdAt, 'transfer creation timestamp', type: :string
#       response_field :updatedAt, 'transfer update timestamp', type: :string
#     end

#     context '200' do
#       let!(:project_id) { project.id }
#       let!(:id) { transfer_paid.id }

#       example 'GET' do
#         explanation 'Returns data for a single transfer.'

#         request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_paid.id, project_id: project.id), 'GET', 'example.org')
#         result = do_request(request)
#         binding.pry
#         expect(status).to eq(200)
#       end
#     end
#   end

#   post '/api/v1/projects/:project_id/transfers' do
#     let(:account) { create(:account, managed_mission: active_whitelabel_mission) }
#     let!(:wallet) { create(:wallet, account: account, _blockchain: project.token._blockchain, address: build(:ethereum_address_1)) }

#     with_options with_example: true do
#       parameter :project_id, 'project id', required: true, type: :integer
#     end

#     with_options with_example: true do
#       response_field :errors, 'array of errors'
#     end

#     with_options scope: :transfer, with_example: true do
#       parameter :amount, 'transfer amount (same decimals as token)', required: true, type: :string
#       parameter :quantity, 'transfer quantity (2 decimals)', required: true, type: :string
#       parameter :total_amount, 'transfer total_amount (amount times quantity, same decimals as token)', required: true, type: :string
#       parameter :account_id, 'transfer account id', required: true, type: :string
#       parameter :transfer_type_id, 'custom transfer type id (default: earned)', required: false, type: :string
#       parameter :recipient_wallet_id, 'custom recipient wallet id', required: false, type: :string
#       parameter :description, 'transfer description', type: :string
#     end

#     context '201' do
#       let!(:project_id) { project.id }

#       let!(:transfer) do
#         {
#           amount: '1000.00000000',
#           quantity: '2.00',
#           total_amount: '2000.00000000',
#           description: 'investor',
#           transfer_type_id: create(:transfer_type, project: project).id.to_s,
#           account_id: account.managed_account_id.to_s,
#           recipient_wallet_id: wallet.id.to_s
#         }
#       end

#       example 'CREATE' do
#         explanation 'Returns created transfer details (See GET for response details)'

#         request = build(:api_signed_request, { transfer: transfer }, api_v1_project_transfers_path(project_id: project.id), 'POST', 'example.org')
#         result = do_request(request)
#         binding.pry
#         if status == 201
#           result[0][:request_path] = '/api/v1/projects/13/transfers'
#           result[0][:request_body] = {
#                                       "body": {
#                                         "data": {
#                                           "transfer": {
#                                             "amount": "1000.00000000",
#                                             "quantity": "2.00",
#                                             "total_amount": "2000.00000000",
#                                             "description": "investor",
#                                             "transfer_type_id": "59",
#                                             "account_id": "d73edec7-a542-437c-887f-5a4d45b2519d",
#                                             "recipient_wallet_id": "2"
#                                           }
#                                         },
#                                         "url": "http://example.org/api/v1/projects/13/transfers",
#                                         "method": "POST",
#                                         "nonce": "bcdf5246d8563612db65c74c5e500a27",
#                                         "timestamp": "1617607700"
#                                       },
#                                       "proof": {
#                                         "type": "Ed25519Signature2018",
#                                         "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#                                         "signature": "BmTQalKHoMdeZZGeaPLtwHCxCoWNMUvlP3xOrHUGN/s4fV137b0ijrOud8NKGxMDdwvx8mwaMoZEy2EAS2uXDg=="
#                                       }
#                                     }
#           result[0][:response_headers]['ETag'] = 'W/"bc27a463161d00ff69911b6d8f8b43df"'
#           result[0][:response_body] = {
#                                         "id": 19,
#                                         "transferTypeId": 59,
#                                         "recipientWalletId": 2,
#                                         "amount": "1000.0",
#                                         "quantity": "2.0",
#                                         "totalAmount": "2000.0",
#                                         "description": "investor",
#                                         "transactionError": null,
#                                         "status": "accepted",
#                                         "createdAt": "2021-04-05T07:28:20.793Z",
#                                         "updatedAt": "2021-04-05T07:28:20.793Z",
#                                         "accountId": "d73edec7-a542-437c-887f-5a4d45b2519d",
#                                         "projectId": 13
#                                       }                   
#         end
#         expect(status).to eq(201)
#       end
#     end

#     context '400' do
#       let!(:project_id) { project.id }

#       let!(:transfer) do
#         {
#           amount: '-1.00',
#           account_id: create(:account, managed_mission: active_whitelabel_mission).managed_account_id.to_s
#         }
#       end

#       example 'CREATE – ERROR' do
#         explanation 'Returns an array of errors'

#         request = build(:api_signed_request, { transfer: transfer }, api_v1_project_transfers_path(project_id: project.id), 'POST', 'example.org')
#         result = do_request(request)
#         if status == 400
#           result[0][:request_path] = '/api/v1/projects/12/transfers'
#           result[0][:request_body] = {
#                                         "body": {
#                                           "data": {
#                                             "transfer": {
#                                               "amount": "-1.00",
#                                               "account_id": "a80f5aa1-9ac8-4f27-8a3b-9f6def0b2c55"
#                                             }
#                                           },
#                                           "url": "http://example.org/api/v1/projects/12/transfers",
#                                           "method": "POST",
#                                           "nonce": "36a0115909376e9698c7113c94d55f8f",
#                                           "timestamp": "1617607699"
#                                         },
#                                         "proof": {
#                                           "type": "Ed25519Signature2018",
#                                           "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#                                           "signature": "yDfI2WB/QCXA3kaKygx03Wi3r4QQ8OPuVOlb+OMhcxWHHMGgtxBTlGM/vAPR1liDBcrihMeeiYoxkJ9ydbj3Cg=="
#                                         }
#                                       }

#           result[0][:response_body] = {
#                                         "errors": {
#                                           "amount": [
#                                             "has incorrect precision (should be 8)"
#                                           ]
#                                         }
#                                       }                            
#         end  
#         expect(status).to eq(400)
#       end
#     end
#   end

#   delete '/api/v1/projects/:project_id/transfers/:id' do
#     with_options with_example: true do
#       parameter :id, 'transfer id', required: true, type: :integer
#       parameter :project_id, 'project id', required: true, type: :integer
#     end

#     with_options with_example: true do
#       response_field :errors, 'array of errors'
#     end

#     context '200' do
#       let!(:id) { transfer_accepted.id }
#       let!(:project_id) { project.id }

#       example 'CANCEL' do
#         explanation 'Returns cancelled transfer details (See GET for response details)'

#         request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_accepted.id, project_id: project.id), 'DELETE', 'example.org')
#         result = do_request(request)
#         binding.pry
#         expect(status).to eq(200)
#       end
#     end

#     context '400' do
#       let!(:id) { transfer_paid.id }
#       let!(:project_id) { project.id }

#       example 'CANCEL – ERROR' do
#         explanation 'Returns an array of errors'

#         request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_paid.id, project_id: project.id), 'DELETE', 'example.org')
#         result = do_request(request)
#         binding.pry
#         expect(status).to eq(400)
#       end
#     end
#   end
# end
