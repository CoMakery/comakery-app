require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'VIII. Reg Groups' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:reg_group) { create(:reg_group) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: reg_group.token) }

  explanation 'Create and delete reg groups, retrieve reg group data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/projects/:project_id/reg_groups' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of reg groups. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_reg_groups_path(project_id: project.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/11/reg_groups?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects%2F11%2Freg_groups&body[method]=GET&body[nonce]=6cab74a83a5c496dace7c406fdad478c&body[timestamp]=1617700101&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=CcNOIK6uQyl2ps4ZTI6SoVFPk0ARxJWXKcE%2B6itMNhwjZRZSL8ztLj7gyyXDHbGecVUNCLC1ev237dqlnZJqAA%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: {"data"=>"", "url"=>"http://example.org/api/v1/projects/11/reg_groups", "method"=>"GET", "nonce"=>"6cab74a83a5c496dace7c406fdad478c", "timestamp"=>"1617700101"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"CcNOIK6uQyl2ps4ZTI6SoVFPk0ARxJWXKcE+6itMNhwjZRZSL8ztLj7gyyXDHbGecVUNCLC1ev237dqlnZJqAA=="}
                                                  }
          result[0][:response_headers]['ETag'] = 'W/"194440b6abad010a97cbd1803dfbda57"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:21 GMT'
          result[0][:response_body] = [
                                        {
                                          "id": 28,
                                          "name": "0",
                                          "tokenId": 26,
                                          "blockchainId": 0,
                                          "createdAt": "2021-04-06T09:08:20.978Z",
                                          "updatedAt": "2021-04-06T09:08:20.978Z"
                                        },
                                        {
                                          "id": 29,
                                          "name": "RegGroup 575478f0848de4163979293f31d705dc78cba818",
                                          "tokenId": 26,
                                          "blockchainId": 1028,
                                          "createdAt": "2021-04-06T09:08:21.010Z",
                                          "updatedAt": "2021-04-06T09:08:21.010Z"
                                        }
                                      ]
        end
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:project_id/reg_groups/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'reg group id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'reg group id', type: :integer
      response_field :name, 'reg group name', type: :integer
      response_field :blockchain_id, 'reg group id on blockchain', type: :integer
      response_field :token_id, 'reg group token id', type: :integer
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { reg_group.id }

      example 'GET' do
        explanation 'Returns data for a single reg group.'

        request = build(:api_signed_request, '', api_v1_project_reg_group_path(id: reg_group.id, project_id: project.id), 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/10/reg_groups/27?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects%2F10%2Freg_groups%2F27&body[method]=GET&body[nonce]=7712687e4495836e3bee049aa8b2e061&body[timestamp]=1617700100&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=HNBAX%2BUSz8uwIX7z9AHY16%2FXm2b3sbIAYJybSEfbYFFnpc%2Br%2BQBQtKULMgIRVair0vTWWoutUiTxgsRTTwwOAQ%3D%3D'
          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/projects/10/reg_groups/27", "method"=>"GET", "nonce"=>"7712687e4495836e3bee049aa8b2e061", "timestamp"=>"1617700100"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"HNBAX+USz8uwIX7z9AHY16/Xm2b3sbIAYJybSEfbYFFnpc+r+QBQtKULMgIRVair0vTWWoutUiTxgsRTTwwOAQ=="}
                                                 }
          result[0][:response_headers]['ETag'] = 'W/"e33792454459bbb88af041dd5505e841"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:19 GMT'
          result[0][:response_body] = {
                                        "id": 27,
                                        "name": "RegGroup a5258000320575397a9b03279969a68217e22042",
                                        "tokenId": 24,
                                        "blockchainId": 1026,
                                        "createdAt": "2021-04-06T09:08:19.949Z",
                                        "updatedAt": "2021-04-06T09:08:19.949Z"
                                      }
        end
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/reg_groups' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :reg_group, with_example: true do
      parameter :name, 'reg group name', required: true, type: :string
      parameter :blockchain_id, 'reg group id on blockchain (will be auto-generated if not provided)', type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:valid_attributes) do
        { name: 'Test' }
      end

      example 'CREATE' do
        explanation 'Returns created reg group details (See GET for response details)'

        request = build(:api_signed_request, { reg_group: valid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          result[0][:request_path] = '/api/v1/projects/12/reg_groups'
          result[0][:request_body] = {
                                        "body": {
                                          "data": {
                                            "reg_group": {
                                              "name": "Test"
                                            }
                                          },
                                          "url": "http://example.org/api/v1/projects/12/reg_groups",
                                          "method": "POST",
                                          "nonce": "0a82a7cdee630bd8ceeb56e533a02e16",
                                          "timestamp": "1617700102"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "EHJo9jaFtqIPLwrbsQOzOEB8FCMqcJm4MD6WwCXyQN3Qeoskq8b2cnvxk62KP8w8kEMp64lH1jyvcLDRImoIAw=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"91c1cb4658d2313c0c5b589a9c86cace"'
          result[0][:response_body] = {
                                        "id": 32,
                                        "name": "Test",
                                        "tokenId": 28,
                                        "blockchainId": 1031,
                                        "createdAt": "2021-04-06T09:08:22.674Z",
                                        "updatedAt": "2021-04-06T09:08:22.674Z"
                                      }
        end
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:invalid_attributes) do
        {
          blockchain_id: '-15'
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { reg_group: invalid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/projects/13/reg_groups'
          result[0][:request_body] = {
                                      "body": {
                                        "data": {
                                          "reg_group": {
                                            "blockchain_id": "-15"
                                          }
                                        },
                                        "url": "http://example.org/api/v1/projects/13/reg_groups",
                                        "method": "POST",
                                        "nonce": "f5bee0a425eb8b5fe934fd92f1ef2439",
                                        "timestamp": "1617700103"
                                      },
                                      "proof": {
                                        "type": "Ed25519Signature2018",
                                        "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                        "signature": "exYV+u2FoSMEKWnXrxyzOIiqtdZ/RdyfA3tIDiFlRKCmqoolhYlnrfe8U3bTU1VNfNW8HLAHfN2sPqSNzTbAAA=="
                                      }
                                    }
        end
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/reg_groups/:id' do
    with_options with_example: true do
      parameter :id, 'reg group id', required: true, type: :integer
      parameter :project_id, 'project id', required: true, type: :integer
    end

    context '200' do
      let!(:id) { reg_group.id }
      let!(:project_id) { project.id }

      example 'DELETE' do
        explanation 'Delete the reg group and returns an array of present reg groups (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_project_reg_group_path(id: reg_group.id, project_id: project.id), 'DELETE', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects/14/reg_groups/36'
          result[0][:request_body] = {
                                      "body": {
                                        "data": "",
                                        "url": "http://example.org/api/v1/projects/14/reg_groups/36",
                                        "method": "DELETE",
                                        "nonce": "2c8f6365228df2824d63b9cff9ed9cc6",
                                        "timestamp": "1617700104"
                                      },
                                      "proof": {
                                        "type": "Ed25519Signature2018",
                                        "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                        "signature": "qhjsWEUgd8GHIdA64SrNb7rV0xtlKZ3pmw+tKL85XIyAQwVNR8VN7pqFFfRrZM7mHZrAnpylEd7SyZzEu5DVBQ=="
                                      }
                                    }
          result[0][:response_headers]['ETag'] = 'W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"'
        end
        expect(status).to eq(200)
      end
    end
  end
end
