require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'III. Projects' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:comakery_dummy_token), account: create(:account, managed_mission: active_whitelabel_mission)) }
  let!(:project2) { create(:project, mission: active_whitelabel_mission, token: create(:comakery_dummy_token), account: create(:account, managed_mission: active_whitelabel_mission)) }

  before do
    3.times { project.admins << create(:account, managed_mission: active_whitelabel_mission) }
  end

  explanation 'Retrieve projects data.'

  header 'API-Key', build(:api_key)

  get '/api/v1/projects' do
    with_options with_example: true do
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of projects. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects&body[method]=GET&body[nonce]=e81ccdafaefa493265d4709cc8aacd83&body[timestamp]=1617689302&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=%2FKr5QHejXV3wLdczoq8vOUWvnE8uyE%2B8awwBZOyYMTYOQbOUlvCmbf0NjuTbgDmNAtD0F2UlhF%2FIzm2OFiwRDQ%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: {"data"=>"", "url"=>"http://example.org/api/v1/projects", "method"=>"GET", "nonce"=>"e81ccdafaefa493265d4709cc8aacd83", "timestamp"=>"1617689302"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"/Kr5QHejXV3wLdczoq8vOUWvnE8uyE+8awwBZOyYMTYOQbOUlvCmbf0NjuTbgDmNAtD0F2UlhF/Izm2OFiwRDQ=="}
                                                  }
          result[0][:response_headers]['ETag'] = 'W/"cef7296a00bd29c580bd5cf81899f61d"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 06:08:11 GMT'
          result[0][:response_body] = [
                                        {
                                          "id": 4,
                                          "title": "Uber for Cats",
                                          "description": "We are going to build amazing",
                                          "imageUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBJQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--df3a9f3afe84f453cc66e5f5a8aef3d6c346a8ed/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtDNkFOcEF1Z0QiLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--6c318e046d2ad6689dcbf9dd2a432c640a9ef2df/dummy_image.png",
                                          "createdAt": "2021-04-06T06:08:22.053Z",
                                          "updatedAt": "2021-04-06T06:08:22.096Z",
                                          "accountId": "401d4e16-1256-49d8-8bcf-39418553482f",
                                          "adminIds": [

                                          ],
                                          "transferTypes": [
                                            {
                                              "id": 13,
                                              "name": "earned"
                                            },
                                            {
                                              "id": 14,
                                              "name": "bought"
                                            },
                                            {
                                              "id": 15,
                                              "name": "mint"
                                            },
                                            {
                                              "id": 16,
                                              "name": "burn"
                                            }
                                          ],
                                          "token": {
                                            "id": 7,
                                            "name": "ComakeryDummyToken-fdd767d005159611fc5454e8791be25c992bab04",
                                            "symbol": "DUMde72b801245eb02c2292cd1c287bb07948f28d9e",
                                            "network": "ethereum_ropsten",
                                            "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                            "decimalPlaces": 0,
                                            "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBIQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--9c6af66ecda0f3d7c92f9bb248a5d292dc852a85/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                            "createdAt": "2021-04-06T06:08:21.563Z",
                                            "updatedAt": "2021-04-06T06:08:22.104Z"
                                          }
                                        },
                                        {
                                          "id": 3,
                                          "title": "Uber for Cats",
                                          "description": "We are going to build amazing",
                                          "imageUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBHZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--c94e1a2dd146fa19d2319a5d58146306016dfd8d/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtDNkFOcEF1Z0QiLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--6c318e046d2ad6689dcbf9dd2a432c640a9ef2df/dummy_image.png",
                                          "createdAt": "2021-04-06T06:08:21.444Z",
                                          "updatedAt": "2021-04-06T06:08:21.490Z",
                                          "accountId": "6d27a763-6ce0-4756-8db8-521f39881f45",
                                          "adminIds": [
                                            "a11534f1-5271-4d04-9b47-09dc663e999d",
                                            "f7e1a648-4d16-46fc-9725-4335a6ba0344",
                                            "29570159-7fcd-4581-91ff-b83e3912ce75"
                                          ],
                                          "transferTypes": [
                                            {
                                              "id": 9,
                                              "name": "earned"
                                            },
                                            {
                                              "id": 10,
                                              "name": "bought"
                                            },
                                            {
                                              "id": 11,
                                              "name": "mint"
                                            },
                                            {
                                              "id": 12,
                                              "name": "burn"
                                            }
                                          ],
                                          "token": {
                                            "id": 5,
                                            "name": "ComakeryDummyToken-c802dcba6b6fe809422f7b317891a00cf8fcbfe5",
                                            "symbol": "DUM2a139e233536444727aacb0363ef90a235842948",
                                            "network": "ethereum_ropsten",
                                            "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                            "decimalPlaces": 0,
                                            "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBGZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--9ec5d2c8cf25187ff99e831991db4720339037de/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                            "createdAt": "2021-04-06T06:08:20.965Z",
                                            "updatedAt": "2021-04-06T06:08:21.497Z"
                                          }
                                        }
                                      ]

        end  
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:id' do
    with_options with_example: true do
      parameter :id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'project id', type: :integer
      response_field :title, 'project title', type: :string
      response_field :description, 'proect description', type: :string
      response_field :imageUrl, 'project image url', type: :string
      response_field :accountId, 'project owner account id', type: :string
      response_field :createdAt, 'project creation timestamp', type: :string
      response_field :updatedAt, 'project update timestamp', type: :string

      response_field :adminIds, 'array of admin account ids', type: :array, items: { type: :string }
      response_field :transferTypes, 'array of transfer types', type: :array, items: { type: :string }

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
      let!(:id) { project.id }

      example 'GET' do
        explanation 'Returns data for a single project.'

        request = build(:api_signed_request, '', api_v1_project_path(id: project.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/1?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects%2F1&body[method]=GET&body[nonce]=cbb9bbb84fda54c19d81cf0b14a7db57&body[timestamp]=1617689292&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=roiyozRGi%2FqYKCWiNLtotba%2B2Cq5mYxdE7zieBXuvbtqE%2B8AdwwlddEUrz3jUDetxjamUqhA0koJCygLbV70Bw%3D%3D'
          result[0][:request_query_parameters] = {body: {"data"=>"", "url"=>"http://example.org/api/v1/projects/1", "method"=>"GET", "nonce"=>"cbb9bbb84fda54c19d81cf0b14a7db57", "timestamp"=>"1617689292"}, proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"roiyozRGi/qYKCWiNLtotba+2Cq5mYxdE7zieBXuvbtqE+8AdwwlddEUrz3jUDetxjamUqhA0koJCygLbV70Bw=="}}
          result[0][:response_headers]['ETag'] = 'W/"cef7296a00bd29c580bd5cf81899f61d"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 06:08:11 GMT'
          result[0][:response_body] = {
                                        "id": 1,
                                        "title": "Uber for Cats",
                                        "description": "We are going to build amazing",
                                        "imageUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBEQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--d711dc211d1fbdbb2d3713121acc83edb87d0dbc/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtDNkFOcEF1Z0QiLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--6c318e046d2ad6689dcbf9dd2a432c640a9ef2df/dummy_image.png",
                                        "createdAt": "2021-04-06T06:08:11.485Z",
                                        "updatedAt": "2021-04-06T06:08:11.597Z",
                                        "accountId": "82bf201e-b215-4f49-bbe3-b0ef7616671b",
                                        "adminIds": [
                                          "309e9f3d-92d4-4a46-ab24-ff78d73a957b",
                                          "6b80816d-6248-44d1-b536-2f9b9fba9d99",
                                          "08a0ee09-609b-4397-83bf-00b0aae34eb1"
                                        ],
                                        "transferTypes": [
                                          {
                                            "id": 1,
                                            "name": "earned"
                                          },
                                          {
                                            "id": 2,
                                            "name": "bought"
                                          },
                                          {
                                            "id": 3,
                                            "name": "mint"
                                          },
                                          {
                                            "id": 4,
                                            "name": "burn"
                                          }
                                        ],
                                        "token": {
                                          "id": 1,
                                          "name": "ComakeryDummyToken-ce13648c2300875a0deca0073d828a23a8f761d8",
                                          "symbol": "DUMd3aebae164a9e3ff2196f62a6e406f1d87f69fac",
                                          "network": "ethereum_ropsten",
                                          "contractAddress": "0x1D1592c28FFF3d3E71b1d29E31147846026A0a37",
                                          "decimalPlaces": 0,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3c9d34e0ca535f7d61aaa45c9814277bf0d85ceb/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T06:08:10.605Z",
                                          "updatedAt": "2021-04-06T06:08:11.604Z"
                                        }
                                      }
        end  
        expect(status).to eq(200)
      end
    end
  end
end
