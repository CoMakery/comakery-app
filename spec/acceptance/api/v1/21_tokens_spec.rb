require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'X. Tokens' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  explanation ['Retrieve data tokens. '\
              'Inflection is managed via `Key-Inflection` request header with values of `camel`, `dash`, `snake` or `pascal`.
               By default requests use snake case, responses use camel case.'].join(' ')

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/tokens' do
    with_options with_example: true do
      response_field :id, 'id', type: :integer
      response_field :name, 'name', type: :string
      response_field :symbol, 'symbol', type: :string
      response_field :network, 'network', type: :string
      response_field :contractAddress, 'contact address', type: :string
      response_field :decimalPlaces, 'decimal places', type: :string
      response_field :imageUrl, 'image url', type: :string
      response_field :createdAt, 'token creation timestamp', type: :string
      response_field :updatedAt, 'token update timestamp', type: :string
    end

    context '200' do
      let!(:cat_token) { create(:token, name: 'Cats') }
      let!(:dog_token) { create(:token, name: 'Dogs', _blockchain: 'cardano') }

      example 'GET' do
        explanation 'Returns tokens.'

        request = build(:api_signed_request, '', api_v1_tokens_path, 'GET', 'example.org')

        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=e145da0e6ac012c45feb9c0b5dcccaf9&body[timestamp]=1617700114&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=it%2BFfUUc8Pi4dGM17gXXyV8KKm2%2FNaJFYTAkEd0Tpnm4p5dHYE7%2BLgkiCNYmZt4N8jKb2oD%2B%2Bkn2%2F%2Bs86UwiAA%3D%3D'
          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"e145da0e6ac012c45feb9c0b5dcccaf9", "timestamp"=>"1617700114"}, 
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"it+FfUUc8Pi4dGM17gXXyV8KKm2/NaJFYTAkEd0Tpnm4p5dHYE7+LgkiCNYmZt4N8jKb2oD++kn2/+s86UwiAA=="}
                                                 }
          result[0][:response_headers]['ETag'] = 'W/"3cbc54b2abd8984b10dedc6d341e5858"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:34 GMT'
          result[0][:request_body] =  [
                                        {
                                          "id": 38,
                                          "name": "Cats",
                                          "symbol": "TKN0d498577f882be573b056b117affd0caeb26776a",
                                          "network": "bitcoin",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBWW89IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--f721919fb6432fb34b7a3badd1a8d577c3cf5c81/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T09:08:33.962Z",
                                          "updatedAt": "2021-04-06T09:08:33.972Z"
                                        },
                                        {
                                          "id": 39,
                                          "name": "Dogs",
                                          "symbol": "TKN4a051d8ca8d31d7d8b113e432e1c8bc4a1bdac68",
                                          "network": "cardano",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBWXM9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--350226bf48046403d668a388d841d19bbedbd07c/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T09:08:34.059Z",
                                          "updatedAt": "2021-04-06T09:08:34.070Z"
                                        }
                                      ]
        end
        expect(status).to eq(200)
      end

      example 'GET – FILTERING WITH OR CONDITION' do
        explanation 'Returns tokens.'

        request = build(:api_signed_request, '', api_v1_tokens_path, 'GET', 'example.org')
        request[:q] = { name_or_symbol_cont: 'Cats' }

        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=d2d92a32acc7f5c8c672bb002739f2d4&body[timestamp]=1617700105&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=3pfLRcpSFXXXxFnnV0cGCRzw23F5sJhlFwEKRZSXogiSwCiIwPEsekPuYN9Ky5r8FyXM6En4qtSjqjA059YFCQ%3D%3D&q[name_or_symbol_cont]=Cats'
          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"d2d92a32acc7f5c8c672bb002739f2d4", "timestamp"=>"1617700105"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"3pfLRcpSFXXXxFnnV0cGCRzw23F5sJhlFwEKRZSXogiSwCiIwPEsekPuYN9Ky5r8FyXM6En4qtSjqjA059YFCQ=="},
                                                   q: {"name_or_symbol_cont"=>"Cats"}
                                                 }
          result[0][:response_headers]['ETag'] = 'W/"15cf8c4ba9893bc577c39f5e67e73a97"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:25 GMT'
          result[0][:request_body] =  [
                                        {
                                          "id": 34,
                                          "name": "Cats",
                                          "symbol": "TKN2ddfb306fca76db1c47f3e5a24381ff6063d3991",
                                          "network": "bitcoin",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBWUk9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--925d494f3afe190c56d219c1e3bf92862561fa5f/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T09:08:25.023Z",
                                          "updatedAt": "2021-04-06T09:08:25.034Z"
                                        }
                                      ]
        end
        expect(status).to eq(200)
      end

      example 'GET – FILTERING WITH AND CONDITION' do
        explanation 'Returns tokens.'

        request = build(:api_signed_request, '', api_v1_tokens_path, 'GET', 'example.org')
        request[:q] = { name_cont: 'Dogs', network_eq: 'cardano' }

        result = do_request(request)
        if status == 200
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=bbb6b4bf6221e8d89abb5ada3f6334a1&body[timestamp]=1617700113&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=0Jzl1KJsKUNKy5V5s3NSrx5xYumOP942gZxzT6WUnyMaoLIZ23HIgRLC9UpoESSK9FsGJOADd5E3RrZsI9wvAA%3D%3D&q[name_cont]=Dogs&q[network_eq]=cardano'
          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"bbb6b4bf6221e8d89abb5ada3f6334a1", "timestamp"=>"1617700113"}, 
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"0Jzl1KJsKUNKy5V5s3NSrx5xYumOP942gZxzT6WUnyMaoLIZ23HIgRLC9UpoESSK9FsGJOADd5E3RrZsI9wvAA=="},
                                                   q: {"name_cont"=>"Dogs", "network_eq"=>"cardano"}
                                                 }
          result[0][:response_headers]['ETag'] = 'W/"a94e98e98c6628d6add2e34b52b7daac"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:33 GMT'
          result[0][:request_body] =  [
                                        {
                                          "id": 37,
                                          "name": "Dogs",
                                          "symbol": "TKN0317c692773bf030f6924201c1b16aa677d2ffad",
                                          "network": "cardano",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBWWM9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--84825de7c8c8a635719892029d55dc9cc64ae5e9/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T09:08:33.481Z",
                                          "updatedAt": "2021-04-06T09:08:33.491Z"
                                        }
                                      ]
          
        end
        expect(status).to eq(200)
      end
    end

    context '400' do
      let!(:cat_token) { create(:token, name: 'Cats') }

      example 'INDEX – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, '', api_v1_tokens_path, 'GET', 'example.org')
        request[:q] = { network_cont: 'bitcoin' }

        result = do_request(request)
        if status == 400
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=091ca0b007c3416f9585c8e577e08586&body[timestamp]=1617700114&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=Eez3sz1NGnabIQGUdMgNsU5CVImXlAyQIyE%2Bj6gnNTbf1kGeVc0SN610C2x5Ut0fC7NaCTCa1%2FhQMEbaE6OYBg%3D%3D&q[network_cont]=bitcoin'
          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"091ca0b007c3416f9585c8e577e08586", "timestamp"=>"1617700114"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"Eez3sz1NGnabIQGUdMgNsU5CVImXlAyQIyE+j6gnNTbf1kGeVc0SN610C2x5Ut0fC7NaCTCa1/hQMEbaE6OYBg=="},
                                                   q: {"network_cont"=>"bitcoin"}
                                                 }
        end
        expect(status).to eq(400)
      end
    end
  end
end
