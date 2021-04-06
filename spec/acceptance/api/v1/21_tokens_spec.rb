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
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=790c6adaeba78e7826b69dc217908ff2&body[timestamp]=1617706324&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=FyfuJ86Otl2xW73QzV4oc6eQQHIn7ON10x1QRjIqEtOQW4pHa8lSfEcicos%2BZzfM2c0Wx0R0cWIpY5k%2B0MzQCQ%3D%3D'

          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"790c6adaeba78e7826b69dc217908ff2", "timestamp"=>"1617706324"},
          proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"FyfuJ86Otl2xW73QzV4oc6eQQHIn7ON10x1QRjIqEtOQW4pHa8lSfEcicos+ZzfM2c0Wx0R0cWIpY5k+0MzQCQ=="}}

          result[0][:response_headers]['ETag'] = 'W/"294c784ecfd71841bea5933ffa76de40"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 10:52:04 GMT'
          result[0][:request_body] =  [
                                        {
                                          "id": 6,
                                          "name": "Cats",
                                          "symbol": "TKN198efd8b622a87cbca6b54a912227e3a280095e8",
                                          "network": "bitcoin",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBFdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--4dc440b26409ea81bbbbb2908d063ce561ecb668/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T10:52:03.995Z",
                                          "updatedAt": "2021-04-06T10:52:04.016Z"
                                        },
                                        {
                                          "id": 7,
                                          "name": "Dogs",
                                          "symbol": "TKN676f3ac72f320bb17911868a001314e3533cd150",
                                          "network": "cardano",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBGQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--8df573f78e89997036793da9b094a6ce19487d2a/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T10:52:04.115Z",
                                          "updatedAt": "2021-04-06T10:52:04.123Z"
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
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=120144664418ae4716a890ca099b5552&body[timestamp]=1617706313&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=cFep5MtjDnw%2FNh8L2m0g8yFsO5wBOekp8qZzl3gNID8lIulWcq9CMuiYL57yl1HlfcphCrtBOWmezvCKJsisCw%3D%3D&q[name_or_symbol_cont]=Cats'

          result[0][:request_query_parameters] = {body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"120144664418ae4716a890ca099b5552", "timestamp"=>"1617706313"}, proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"cFep5MtjDnw/Nh8L2m0g8yFsO5wBOekp8qZzl3gNID8lIulWcq9CMuiYL57yl1HlfcphCrtBOWmezvCKJsisCw=="}, q: {"name_or_symbol_cont"=>"Cats"}}

          result[0][:response_headers]['ETag'] = 'W/"295caf1489fb5ec5cc0ae211203e0b3d"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 10:51:52 GMT'
          result[0][:response_body] = [
                                        {
                                          "id": 2,
                                          "name": "Cats",
                                          "symbol": "TKNc189f57daac654a1a0d26462bca955b533192bd5",
                                          "network": "bitcoin",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--4f6ed62d6d0ad4f4d3a9b5450db15d37e9bf0d03/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T10:51:52.826Z",
                                          "updatedAt": "2021-04-06T10:51:52.838Z"
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
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=1a3a4a0a24ee7e7e67ef45cb642f9db1&body[timestamp]=1617706323&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=%2F3%2FSxfIspuy46fRXp8TBcvMKEcEfgw2T%2BOIQHFRYF5AYptQfdkjnBmBHoIwEnlTzn9SOqMIDH4%2FV0zENbOwXAQ%3D%3D&q[name_cont]=Dogs&q[network_eq]=cardano'

          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"1a3a4a0a24ee7e7e67ef45cb642f9db1", "timestamp"=>"1617706323"}, proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"/3/SxfIspuy46fRXp8TBcvMKEcEfgw2T+OIQHFRYF5AYptQfdkjnBmBHoIwEnlTzn9SOqMIDH4/V0zENbOwXAQ=="}, q: {"name_cont"=>"Dogs", "network_eq"=>"cardano"}}

          result[0][:response_headers]['ETag'] = 'W/"a94e98e98c6628d6add2e34b52b7daac"'
          result[0][:response_headers]['Last-Modified'] = 'Tue, 06 Apr 2021 09:08:33 GMT'
          result[0][:request_body] =  [
                                        {
                                          "id": 5,
                                          "name": "Dogs",
                                          "symbol": "TKN8fcf275d20fbcc09fd3ef3d406e95efa68d7c3e9",
                                          "network": "cardano",
                                          "contractAddress": nil,
                                          "decimalPlaces": 8,
                                          "logoUrl": "/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBFQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--60eaf7f6794fa2f17153d250ac7aa3c463f51823/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmxwYVdrPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4c450acf028fc76954d30c4ba0ae434ade109266/dummy_image.png",
                                          "createdAt": "2021-04-06T10:52:03.509Z",
                                          "updatedAt": "2021-04-06T10:52:03.524Z"
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
          result[0][:request_path] = '/api/v1/tokens?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Ftokens&body[method]=GET&body[nonce]=7becc225fec777f9e234e1e882f9e8d2&body[timestamp]=1617706312&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=q70OmhtugHZ0UpJ4MQZ4DkgTooaptvrMd2odC%2F2RdfDDhVs5G8YiZaclC5n5nGE7SN62mf9eShkRKl8IzfXjAA%3D%3D&q[network_cont]=bitcoin'

          result[0][:request_query_parameters] = {body: {"data"=>"", "url"=>"http://example.org/api/v1/tokens", "method"=>"GET", "nonce"=>"7becc225fec777f9e234e1e882f9e8d2", "timestamp"=>"1617706312"}, proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"q70OmhtugHZ0UpJ4MQZ4DkgTooaptvrMd2odC/2RdfDDhVs5G8YiZaclC5n5nGE7SN62mf9eShkRKl8IzfXjAA=="}, q: {"network_cont"=>"bitcoin"}}
        end
        expect(status).to eq(400)
      end
    end
  end
end
