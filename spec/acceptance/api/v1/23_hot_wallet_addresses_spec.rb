# require 'rails_helper'
# require 'rspec_api_documentation/dsl'

# resource 'XII. Hot Wallet Addresses' do
#   include Rails.application.routes.url_helpers

#   let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
#   let!(:project) { create(:project, mission: active_whitelabel_mission, api_key: ApiKey.new(key: build(:api_key))) }

#   let(:valid_attributes) { { address: build(:wallet).address } }

#   explanation 'Register hot wallets with a project.'

#   header 'API-Transaction-Key', build(:api_key)
#   header 'Content-Type', 'application/json'

#   post '/api/v1/projects/:project_id/hot_wallet_addresses' do
#     with_options with_example: true do
#       parameter :name, 'wallet name ("Hot Wallet" by default)', required: false, type: :string
#       parameter :address, 'wallet address', required: true, type: :string
#     end

#     context '201' do
#       let!(:project_id) { project.id }
#       let!(:create_params) { { hot_wallet: valid_attributes } }

#       example 'CREATE HOT WALLET' do
#         explanation 'Returns created hot wallet'

#         params = { body: { data: create_params } }
#         result = do_request(params)
#         if status == 201
#           result[0][:request_path] = '/api/v1/projects/59/hot_wallet_addresses'
#           result[0][:request_body] = {
#                                         "body": {
#                                           "data": {
#                                             "hot_wallet": {
#                                               "address": "3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt"
#                                             }
#                                           }
#                                         }
#                                       }
#           result[0][:response_headers]['ETag'] = 'W/"6d059c3cd61ab699056aecb454de5ab8"'
#           result[0][:response_body] = {
#                                         "id": 17,
#                                         "name": "Hot Wallet",
#                                         "address": "3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt",
#                                         "primaryWallet": true,
#                                         "source": "hot_wallet",
#                                         "state": "ok",
#                                         "createdAt": "2021-04-05T07:29:13.430Z",
#                                         "updatedAt": "2021-04-05T07:29:13.430Z",
#                                         "blockchain": "bitcoin",
#                                         "provisionTokens": [

#                                         ]
#                                       }                         
#         end
#         expect(status).to eq(201)
#       end
#     end

#     context '422' do
#       let!(:project_id) { project.id }
#       let!(:create_params) { { hot_wallet: valid_attributes } }

#       before do
#         create(:wallet, source: :hot_wallet, project_id: project.id)
#       end

#       example 'CREATE HOT WALLET – ERROR' do
#         explanation 'Returns an array of errors'

#         params = { body: { data: create_params } }
#         result = do_request(params)
#         if status == 422
#           result[0][:request_path] = '/api/v1/projects/60/hot_wallet_addresses'
#           result[0][:request_body] = {
#                                         "body": {
#                                           "data": {
#                                             "hot_wallet": {
#                                               "address": "3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt"
#                                             }
#                                           }
#                                         }
#                                       }
#           result[0][:response_body] = {
#                                         "errors": {
#                                           "hotWallet": "already exists"
#                                         }
#                                       }                

#         end
#         expect(status).to eq(422)
#       end
#     end
#   end
# end
