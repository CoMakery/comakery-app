require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'V. Transfer Rules' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:transfer_rule) { create(:transfer_rule) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: transfer_rule.token) }

  explanation 'Create and delete transfer rules, retrieve transfer rules data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/projects/:project_id/transfer_rules' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of transfer rules. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_transfer_rules_path(project_id: project.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/4/transfer_rules?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects%2F4%2Ftransfer_rules&body[method]=GET&body[nonce]=8bf828bc4aaa7b131beaf1f1a2506e56&body[timestamp]=1617693635&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=aW23XD8uLamFhQMXzuVfL7%2BLBJKbYCL7O%2Fn0WTARMg0rEn2GWNOHigiErQVio%2FbkkGNyBTswF7Y%2BKUSmfRBFCg%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: {"data"=>"", "url"=>"http://example.org/api/v1/projects/4/transfer_rules", "method"=>"GET", "nonce"=>"8bf828bc4aaa7b131beaf1f1a2506e56", "timestamp"=>"1617693635"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"aW23XD8uLamFhQMXzuVfL7+LBJKbYCL7O/n0WTARMg0rEn2GWNOHigiErQVio/bkkGNyBTswF7Y+KUSmfRBFCg=="}
                                                  }
          result[0][:response_headers]['ETag'] = 'W/"a7673597d3cd94cb1b0e67920c82eade"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 07:20:34 GMT'
          result[0][:response_body] = [
                                        {
                                          "id": 5,
                                          "tokenId": 7,
                                          "sendingGroupId": 13,
                                          "receivingGroupId": 14,
                                          "lockupUntil": "2021-04-05T07:20:34.000Z",
                                          "status": "created",
                                          "createdAt": "2021-04-06T07:20:34.650Z",
                                          "updatedAt": "2021-04-06T07:20:34.650Z"
                                        }
                                      ]            
        end
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:project_id/transfer_rules/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'transfer rule id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'transfer rule id', type: :integer
      response_field :token_id, 'transfer rule token id', type: :integer
      response_field :sending_group_id, 'sending reg group token id', type: :integer
      response_field :receiving_group_id, 'reveiving reg group token id', type: :integer
      response_field :lockup_until, 'lockup until', type: :integer
      response_field :status, 'transfer rule status (created synced)', type: :string
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { transfer_rule.id }

      example 'GET' do
        explanation 'Returns data for a single transfer rule.'

        request = build(:api_signed_request, '', api_v1_project_transfer_rule_path(id: transfer_rule.id, project_id: project.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/5/transfer_rules/6?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects%2F5%2Ftransfer_rules%2F6&body[method]=GET&body[nonce]=97bceb19e77e008d2464e8dbc0fd1a8d&body[timestamp]=1617693636&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=mTINkSGKNAogMeInP32zDa4hKpLjmy9ayxbIdSEfK%2FU7Hj8t3nN9ZmuHzhogFVKZmy%2Fh6G6krqnO8i7tCv4vCw%3D%3D'
          result[0][:request_query_parameters] = {body: {"data"=>"", "url"=>"http://example.org/api/v1/projects/5/transfer_rules/6", "method"=>"GET", "nonce"=>"97bceb19e77e008d2464e8dbc0fd1a8d", "timestamp"=>"1617693636"},
                                                  proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"mTINkSGKNAogMeInP32zDa4hKpLjmy9ayxbIdSEfK/U7Hj8t3nN9ZmuHzhogFVKZmy/h6G6krqnO8i7tCv4vCw=="}
                                                }
          result[0][:response_headers]['ETag'] = 'W/"3714dd72254ad4de133cc55d71f8c333"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 07:20:35 GMT'
          result[0][:response_body] = {
                                        "id": 6,
                                        "tokenId": 9,
                                        "sendingGroupId": 16,
                                        "receivingGroupId": 17,
                                        "lockupUntil": "2021-04-05T07:20:35.000Z",
                                        "status": "created",
                                        "createdAt": "2021-04-06T07:20:35.647Z",
                                        "updatedAt": "2021-04-06T07:20:35.647Z"
                                      }
        end
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/transfer_rules' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :transfer_rule, with_example: true do
      parameter :sending_group_id, 'sending reg group id', required: true, type: :string
      parameter :receiving_group_id, 'receiving reg group id', required: true, type: :string
      parameter :lockup_until, 'lockup until', required: true, type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:valid_attributes) do
        {
          sending_group_id: create(:reg_group, token: transfer_rule.token).id.to_s,
          receiving_group_id: create(:reg_group, token: transfer_rule.token).id.to_s,
          lockup_until: '1'
        }
      end

      example 'CREATE' do
        explanation 'Returns created transfer rule details (See GET for response details)'

        request = build(:api_signed_request, { transfer_rule: valid_attributes }, api_v1_project_transfer_rules_path(project_id: project.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/projects/3/transfer_rules'
          result[0][:request_body] = {
                                        "body": {
                                          "data": {
                                            "transfer_rule": {
                                              "sending_group_id": "10",
                                              "receiving_group_id": "11",
                                              "lockup_until": "1"
                                            }
                                          },
                                          "url": "http://example.org/api/v1/projects/3/transfer_rules",
                                          "method": "POST",
                                          "nonce": "ac1d480cbc43d1a71df1f2baa5af0b5c",
                                          "timestamp": "1617693634"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "fOTEXyAhypvXfbcj9qqVi8J0FqAF56LG5G7cCybbdOSxZi5tFwd8jHlo3c/R6X6mmgm78Z52ady98qxldamNBQ=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"62cb1f4f9bf31164e2309cceeec71a3b"'
          result[0][:response_body] = {
                                        "id": 4,
                                        "tokenId": 5,
                                        "sendingGroupId": 10,
                                        "receivingGroupId": 11,
                                        "lockupUntil": "1970-01-01T00:00:01.000Z",
                                        "status": "created",
                                        "createdAt": "2021-04-06T07:20:34.312Z",
                                        "updatedAt": "2021-04-06T07:20:34.312Z"
                                      }
        end
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:invalid_attributes) do
        {
          sending_group_id: '945677752'
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { transfer_rule: invalid_attributes }, api_v1_project_transfer_rules_path(project_id: project.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/projects/2/transfer_rules'
          result[0][:request_body] = {
                                        "body": {
                                          "data": {
                                            "transfer_rule": {
                                              "sending_group_id": "945677752"
                                            }
                                          },
                                          "url": "http://example.org/api/v1/projects/2/transfer_rules",
                                          "method": "POST",
                                          "nonce": "ffa2a86735ff38c117e146067d47144a",
                                          "timestamp": "1617693633"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "YQQsgueEATcFm30KLveIK9eS3Y8vly+n8b/4kTXD41QoPL8iNnlnNdi2+oJVvmjsuzdN0uIKKRgL+aCqsMN+AA=="
                                        }
                                      }
          result[0][:response_body] = {
                                        "errors": {
                                          "sendingGroup": [
                                            "should belong to ComakeryDummyToken-51904dcc7d9b1a275e0aa99e75b1aad72301d7f7 token"
                                          ],
                                          "receivingGroup": [
                                            "should belong to ComakeryDummyToken-51904dcc7d9b1a275e0aa99e75b1aad72301d7f7 token"
                                          ]
                                        }
                                      }
        end
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/transfer_rules/:id' do
    with_options with_example: true do
      parameter :id, 'transfer rule id', required: true, type: :integer
      parameter :project_id, 'project id', required: true, type: :integer
    end

    context '200' do
      let!(:id) { transfer_rule.id }
      let!(:project_id) { project.id }

      example 'DELETE' do
        explanation 'Delete the tranfer rule and returns an array of present transfer rules (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_project_transfer_rule_path(id: transfer_rule.id, project_id: project.id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/1/transfer_rules/1'
          result[0][:response_headers]['ETag'] = 'W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"'
          result[0][:request_body] =  {
                                        "body": {
                                          "data": "",
                                          "url": "http://example.org/api/v1/projects/1/transfer_rules/1",
                                          "method": "DELETE",
                                          "nonce": "9c38efe6518707b5efc1b261a8553a64",
                                          "timestamp": "1617693632"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "KsX6acQPUr/oo+GfC1DNZxRt+/tfXZv2DQCUteHGmbpm8jhs4wdDJRgiPZ0oX9dNOBhHNs8zdKi/rr88ZsVaBg=="
                                        }
                                      }

          result[0][:response_body] = []
        end
        expect(status).to eq(200)
      end
    end
  end
end
