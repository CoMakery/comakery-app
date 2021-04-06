require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'I. General' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:comakery_token)) }

  explanation 'Details on authentication, caching, throttling, inflection and pagination.'

  header 'API-Key', build(:api_key)

  get '/api/v1/projects' do
    with_options scope: :body, with_example: true do
      parameter :data, 'request data', required: true
      parameter :url, 'request url', required: true
      parameter :method, 'request http method', required: true
      parameter :nonce, 'request nonce (rotated every 24h)', required: true
      parameter :timestamp, 'request timestamp (expires in 60 seconds)', required: true
    end

    with_options scope: :proof, with_example: true do
      parameter :type, 'Ed25519Signature2018', required: true
      parameter :verificationMethod, 'public key', required: true
      parameter :signature, 'request signature', required: true
    end

    context '200' do
      example 'AUTHENTICATION' do
        explanation [
          'Requests should include `API-Key` header and a correct proof based on `Ed25519Signature2018` in the format described below.' \
          'All values should be strings.' \
          'Note 1: When calculating the signature, request data should be serialized according JSON Canonicalization Scheme.' \
          'Note 2: Blockchain Transactions (VII) endpoints do not require proof and can be accessed with either `API-Key` or `API-Transaction-Key` header. See section VII for examples.'
        ].join(' ')

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects?body[method]=GET&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects&body[nonce]=b455d909a51aff4b5139c9d47bca8fe7&body[timestamp]=1617622041&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=1EJwwvEQgG31QU6tayy7d9fGswncsT5fmWXDom9yPWbfKiDH9jjL8JpjELvu1y7QaVw1m%2B9DDHELslitpVrSAw%3D%3D'
          result[0][:request_query_parameters] = { body: { 'method' => 'GET', 'data' => '', 'url' => 'http://example.org/api/v1/projects', 'nonce' => 'b455d909a51aff4b5139c9d47bca8fe7', 'timestamp' => '1617622041' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => '1EJwwvEQgG31QU6tayy7d9fGswncsT5fmWXDom9yPWbfKiDH9jjL8JpjELvu1y7QaVw1m+9DDHELslitpVrSAw==' } }
          result[0][:response_headers]['ETag'] = 'ETag: W/"65619e25d426a61fdaaea38f54f63b1f"'
          result[0][:response_headers]['Last-Modified'] = 'Mon, 05 Apr 2021 11:08:13 GMT'
          result[0][:response_body] = [
            {
              "id": 5,
              "title": 'Uber for Cats',
              "description": 'We are going to build amazing',
              "imageUrl": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBMQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--03ce32f1a5950702b7a72d4c89b0f983dee2b518/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtDNkFOcEF1Z0QiLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--6c318e046d2ad6689dcbf9dd2a432c640a9ef2df/dummy_image.png',
              "createdAt": '2021-04-05T11:08:13.552Z',
              "updatedAt": '2021-04-05T11:08:13.594Z',
              "accountId": nil,
              "adminIds": [],
              "transferTypes": [
                {
                  "id": 17,
                  "name": 'earned'
                },
                {
                  "id": 18,
                  "name": 'bought'
                },
                {
                  "id": 19,
                  "name": 'mint'
                },
                {
                  "id": 20,
                  "name": 'burn'
                }
              ],
              "token": {
                "id": 9,
                "name": 'ComakeryToken-949768f7a46a9b5964a1555f79e664ada766c45c',
                "symbol": 'XYZ9a095f8d20ba2331e84b83b994a036359a7fb4a8',
                "network": 'ethereum_ropsten',
                "contractAddress": '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
                "decimalPlaces": 18,
                "logoUrl": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBLQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a69f935c29e7b618dab03fe9610af2f611d106af/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png',
                "createdAt": '2021-04-05T11:08:13.083Z',
                "updatedAt": '2021-04-05T11:08:13.601Z'
              }
            }
          ]
        end

        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects' do
    header 'API-Key', '12345'

    context '401' do
      example 'AUTHENTICATION – INCORRECT PUBLIC KEY HEADER' do
        explanation 'Requests with incorrect public key header will be denied.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        if status == 401
          result[0][:request_path] = '/api/v1/projects?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects&body[method]=GET&body[nonce]=286a93b77b71f1e7557d143b861f3d78&body[timestamp]=1617622941&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=ZTJeDL%2FwB%2BBohqeNYlVzatYVQnmS6ftNwtSL9k5empCfDa1u5fhxxf%2Fi%2Fm2HNzN681wQeqzXnIXL6rIcA%2B3zCA%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/projects', 'method' => 'GET', 'nonce' => '286a93b77b71f1e7557d143b861f3d78', 'timestamp' => '1617622941' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'ZTJeDL/wB+BohqeNYlVzatYVQnmS6ftNwtSL9k5empCfDa1u5fhxxf/i/m2HNzN681wQeqzXnIXL6rIcA+3zCA==' } }
          result[0][:response_body] = {
            "errors": {
              "authentication": 'Missing an authorization'
            }
          }
        end
        expect(status).to eq(401)
      end
    end
  end

  get '/api/v1/projects' do
    context '401' do
      example 'AUTHENTICATION – INCORRECT PROOF' do
        explanation 'Requests with incorrect proof, url, method, timestamp or nonce will be denied.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example1.org')
        result = do_request(request)
        if status == 401
          result[0][:request_path] = '/api/v1/projects?body[data]=&body[url]=http%3A%2F%2Fexample1.org%2Fapi%2Fv1%2Fprojects&body[method]=GET&body[nonce]=f3b738f417028765ca4b2915a97a1fac&body[timestamp]=1617623160&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=7kC9ds3EvewQjap5gMwWeoZf31zyo74ohifXVL0SPJ4ecXc8GRffqWEb1wRcwthcAaGgEbtdWSthagH1VE1VDw%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example1.org/api/v1/projects', 'method' => 'GET', 'nonce' => 'f3b738f417028765ca4b2915a97a1fac', 'timestamp' => '1617623160' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => '7kC9ds3EvewQjap5gMwWeoZf31zyo74ohifXVL0SPJ4ecXc8GRffqWEb1wRcwthcAaGgEbtdWSthagH1VE1VDw==' } }
          result[0][:response_body] = {
            "errors": {
              "authentication": 'Invalid URL'
            }
          }

        end
        expect(status).to eq(401)
      end
    end
  end

  get '/api/v1/projects' do
    header 'If-Modified-Since', :if_modified

    context '304' do
      let!(:if_modified) { project.updated_at.httpdate }

      example 'CACHING' do
        explanation 'Responses include weak `ETag` and `Last-Modified` headers. Server will return HTTP 304 when applicable if request includes valid `If-Modified-Since` header.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        if status == 304
          result[0][:request_path] = '/api/v1/projects?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects&body[method]=GET&body[nonce]=eeeff8907f22e98dadb16fa49a2f19da&body[timestamp]=1617623560&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=1wjluanePegaT0UCyvv9nrtkNoD83cwqalmKuAGsfJWTb3r1X46C7y%2F4V7g5GSfjslLbLQoqV4kA1fTZAup6Dg%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/projects', 'method' => 'GET', 'nonce' => 'eeeff8907f22e98dadb16fa49a2f19da', 'timestamp' => '1617623560' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => '1wjluanePegaT0UCyvv9nrtkNoD83cwqalmKuAGsfJWTb3r1X46C7y/4V7g5GSfjslLbLQoqV4kA1fTZAup6Dg==' } }
          result[0][:response_headers]['ETag'] = 'W/"e1ecbd938491cc1765caf2c0ea693a2c"'
          result[0][:response_headers]['Last-Modified'] = 'Mon, 05 Apr 2021 11:52:40 GMT'
          result[0][:request_headers]['If-Modified-Since'] = 'Mon, 05 Apr 2021 11:52:40 GMT'
        end
        expect(status).to eq(304)
      end
    end
  end

  get '/api/v1/projects' do
    context '429' do
      before do
        Rails.cache.write("rack::attack:#{Time.now.to_i / 60}:api/ip:127.0.0.1", 1001)
      end

      after do
        Rails.cache.clear
      end

      example 'THROTTLING' do
        explanation 'Requests are throttled to 1000rpm per origin to avoid service interruption. On exceeding the limit server will return HTTP 429.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        if status == 429
          result[0][:request_path] = '/api/v1/projects?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects&body[method]=GET&body[nonce]=7e65ef853aae2ed18aee487025895ac1&body[timestamp]=1617624287&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=UzDd3c5p8561zLqiL8XEeob2ZyXOdzg0%2FkKROk3oaO3fJDmmNyL6buuGMKB7ThouzS5TRfO66fl3ZjD1O7xkCw%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/projects', 'method' => 'GET', 'nonce' => '7e65ef853aae2ed18aee487025895ac1', 'timestamp' => '1617624287' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'UzDd3c5p8561zLqiL8XEeob2ZyXOdzg0/kKROk3oaO3fJDmmNyL6buuGMKB7ThouzS5TRfO66fl3ZjD1O7xkCw==' } }

        end
        expect(status).to eq(429)
      end
    end
  end

  get '/api/v1/projects' do
    header 'Key-Inflection', :key_inflection

    context '200' do
      let!(:key_inflection) { 'dash' }

      example 'INFLECTION' do
        explanation 'Inflection is managed via `Key-Inflection` request header with values of `camel`, `dash`, `snake` or `pascal`. By default requests use snake case, responses use camel case.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects&body[method]=GET&body[nonce]=ab7ad0b94b9b42e44ae18b35a5c01632&body[timestamp]=1617624543&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=yJ5jiBUHEQCNdgczSR4CKkCtvAnuKITshK9hGC%2B%2BFsfgdoKigQwx05cVOxXp%2FgUkjoIOMTtL9D%2FV5U1dreX3Bw%3D%3D'
          result[0][:request_query_parameters] = { body: { 'data' => '', 'url' => 'http://example.org/api/v1/projects', 'method' => 'GET', 'nonce' => 'ab7ad0b94b9b42e44ae18b35a5c01632', 'timestamp' => '1617624543' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'yJ5jiBUHEQCNdgczSR4CKkCtvAnuKITshK9hGC++FsfgdoKigQwx05cVOxXp/gUkjoIOMTtL9D/V5U1dreX3Bw==' } }
          result[0][:response_headers]['Last-Modified'] = 'Mon, 05 Apr 2021 11:52:40 GMT'
          result[0][:response_headers]['ETag'] = 'W/"e1ecbd938491cc1765caf2c0ea693a2c"'
          result[0][:response_body] = [
            {
              "id": 1,
              "title": 'Uber for Cats',
              "description": 'We are going to build amazing',
              "image-url": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBEQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--d711dc211d1fbdbb2d3713121acc83edb87d0dbc/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtDNkFOcEF1Z0QiLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--6c318e046d2ad6689dcbf9dd2a432c640a9ef2df/dummy_image.png',
              "created-at": '2021-04-05T12:09:03.020Z',
              "updated-at": '2021-04-05T12:09:03.148Z',
              "account-id": nil,
              "admin-ids": [],
              "transfer-types": [
                {
                  "id": 1,
                  "name": 'earned'
                },
                {
                  "id": 2,
                  "name": 'bought'
                },
                {
                  "id": 3,
                  "name": 'mint'
                },
                {
                  "id": 4,
                  "name": 'burn'
                }
              ],
              "token": {
                "id": 1,
                "name": 'ComakeryToken-11e371788e61103c7a8b758c32b8223905730fa8',
                "symbol": 'XYZ3abf36270b571f846de69409a0789d46336b7af9',
                "network": 'ethereum_ropsten',
                "contract-address": '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
                "decimal-places": 18,
                "logo-url": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3c9d34e0ca535f7d61aaa45c9814277bf0d85ceb/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png',
                "created-at": '2021-04-05T12:09:02.060Z',
                "updated-at": '2021-04-05T12:09:03.156Z'
              }
            }
          ]

        end
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects' do
    with_options with_example: true do
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:page) { 1 }

      example 'PAGINATION' do
        explanation 'Pagination is implemented according RFC-8288 (`Page` request parameter; `Link`, `Total`, `Per-Page` response headers).'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/projects?page=1&body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fprojects&body[method]=GET&body[nonce]=956ddac17e8cd01d47219ea143f0f99f&body[timestamp]=1617624905&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=g1GFJ6ReQnzh7fNSFFEp5u0uqBBMZEgvs2rfJTYv4ovFCwVWaFP8q8uBcKw8maErvgWsMh6Thgk1WrM9kwS9Aw%3D%3D'
          result[0][:request_query_parameters] = { page: 1,
                                                   body: { 'data' => '', 'url' => 'http://example.org/api/v1/projects', 'method' => 'GET', 'nonce' => '956ddac17e8cd01d47219ea143f0f99f', 'timestamp' => '1617624905' },
                                                   proof: { 'type' => 'Ed25519Signature2018', 'verificationMethod' => 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=', 'signature' => 'g1GFJ6ReQnzh7fNSFFEp5u0uqBBMZEgvs2rfJTYv4ovFCwVWaFP8q8uBcKw8maErvgWsMh6Thgk1WrM9kwS9Aw==' } }
          result[0][:response_headers]['Last-Modified'] = 'Mon, 05 Apr 2021 12:15:05 GMT'
          result[0][:response_headers]['ETag'] = 'W/"5fa3c6359b49359241b800a7b6135cbe"'
          result[0][:response_body] = [
            {
              "id": 1,
              "title": 'Uber for Cats',
              "description": 'We are going to build amazing',
              "imageUrl": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBEQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--d711dc211d1fbdbb2d3713121acc83edb87d0dbc/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtDNkFOcEF1Z0QiLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--6c318e046d2ad6689dcbf9dd2a432c640a9ef2df/dummy_image.png',
              "createdAt": '2021-04-05T12:15:05.023Z',
              "updatedAt": '2021-04-05T12:15:05.141Z',
              "accountId": nil,
              "adminIds": [],
              "transferTypes": [
                {
                  "id": 1,
                  "name": 'earned'
                },
                {
                  "id": 2,
                  "name": 'bought'
                },
                {
                  "id": 3,
                  "name": 'mint'
                },
                {
                  "id": 4,
                  "name": 'burn'
                }
              ],
              "token": {
                "id": 1,
                "name": 'ComakeryToken-dabfcff650e0abd0d8deab3f2c10ec98eb104a6f',
                "symbol": 'XYZ653e1aa90508d7f4635d1e23cbf1233ab5fa15ac',
                "network": 'ethereum_ropsten',
                "contractAddress": '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
                "decimalPlaces": 18,
                "logoUrl": '/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3c9d34e0ca535f7d61aaa45c9814277bf0d85ceb/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png',
                "createdAt": '2021-04-05T12:15:04.092Z',
                "updatedAt": '2021-04-05T12:15:05.150Z'
              }
            }
          ]

        end
        expect(status).to eq(200)
      end
    end
  end
end
