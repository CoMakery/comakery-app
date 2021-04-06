# require 'rails_helper'
# require 'rspec_api_documentation/dsl'

# resource 'XI. Wallet Recovery' do
#   include Rails.application.routes.url_helpers

#   let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
#   let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: nil, wallet_recovery_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
#   let(:private_wrapping_key) { '18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725' }
#   let(:public_wrapping_key) { '0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6' }

#   explanation 'Recover data, which was ECIES-encrypted with provided secp256k1 public key. Please use wallet recovery private key to sign requests.'

#   header 'API-Key', build(:api_key)
#   header 'Content-Type', 'application/json'

#   before do
#     allow(ENV).to receive(:fetch).with('WALLET_RECOVERY_WRAPPING_KEY', 'default_key').and_return(private_wrapping_key)
#   end

#   get '/api/v1/wallet_recovery/public_wrapping_key' do
#     subject do
#       do_request(
#         build(
#           :api_signed_request,
#           '',
#           api_v1_wallet_recovery_public_wrapping_key_path,
#           'GET',
#           'example.org'
#         )
#       )
#     end

#     with_options with_example: true do
#       response_field :public_wrapping_key, 'secp256k1 public wrapping key in hex', type: :string
#     end

#     context '200' do
#       example 'GET PUBLIC WRAPPING KEY' do
#         explanation 'Returns a public wrapping key.'
#         result = subject
#         binding.pry
#         if result == 200
#           result[0][:request_path] = "/api/v1/wallet_recovery/public_wrapping_key?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fwallet_recovery%2Fpublic_wrapping_key&body[method]=GET&body[nonce]=376db9aff10358828c949705682e0e55&body[timestamp]=1617607734&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=G4FwXEJzucm%2FQBbZ1YhWHsrWJfNJuS%2BwwHxdoVL%2FcnR0y%2FEO%2FxpKrOwqtfyef6NitsfkhlF4HVsAzo25VoBqCA%3D%3D"

#           result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/wallet_recovery/public_wrapping_key", "method"=>"GET", "nonce"=>"376db9aff10358828c949705682e0e55", "timestamp"=>"1617607734"}, proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"G4FwXEJzucm/QBbZ1YhWHsrWJfNJuS+wwHxdoVL/cnR0y/EO/xpKrOwqtfyef6NitsfkhlF4HVsAzo25VoBqCA=="}
#           }
#           result[0][:response_headers]['ETag'] = 'W/"4e8d0fe4422ce938bb88f3f3a5be2c81"'
#           result[0][:response_body] = { "publicWrappingKey": "0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6" }
#         end  
#         expect(status).to eq(200)
#       end
#     end

#     context '500' do
#       let(:private_wrapping_key) { '' }

#       example 'GET PUBLIC WRAPPING KEY – ERROR' do
#         explanation 'Returns array of errors'
#         result = subject
#         binding.pry
#         if status == 500
#           result[0][:request_path] = "/api/v1/wallet_recovery/public_wrapping_key?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fwallet_recovery%2Fpublic_wrapping_key&body[method]=GET&body[nonce]=e1cacc75765bb76eeebcce0f6cae6d65&body[timestamp]=1617607733&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=X%2BTAnS1CgauNq9D%2FDQ0gIZjQBPIJRltTXA7FMz2GeKXwHsKf6%2F0c%2FiEQDJoD8g8p9c%2Bg3KoH80oX4CJI1WsGCw%3D%3D"
#           result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/wallet_recovery/public_wrapping_key", "method"=>"GET", "nonce"=>"e1cacc75765bb76eeebcce0f6cae6d65", "timestamp"=>"1617607733"},
#                                                    proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"X+TAnS1CgauNq9D/DQ0gIZjQBPIJRltTXA7FMz2GeKXwHsKf6/0c/iEQDJoD8g8p9c+g3KoH80oX4CJI1WsGCw=="}
#                                                   }
#           result[0][:response_body] = { "errors": { "wrappingKeyPrivate": "is invalid" } }                                     
#         end  
#         expect(status).to eq(500)
#       end
#     end
#   end

#   post '/api/v1/wallet_recovery/recover' do
#     let(:api_request_log) { create(:api_request_log, body: { 'account_id' => account.managed_account_id }) }
#     let(:recovery_token) { api_request_log.signature }
#     let(:transport_public_key) { '048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917' }
#     let(:transport_private_key) { 'ADE3E0761CEB242A1BE92043825CD7C677A9A7E25C31F05F4D88DF4D13E2919C' }
#     let(:kdf_shared_info) { 'dummyoreidaccountname' }
#     let(:original_message) { 'Hello :)' }

#     let(:payload) do
#       ECIES::Crypt.new(
#         kdf_shared_info: kdf_shared_info
#       ).encrypt(
#         ECIES::Crypt.public_key_from_hex(public_wrapping_key),
#         original_message
#       ).unpack1('H*')
#     end

#     with_options with_example: true do
#       response_field :data, 'payload, ECIES-decrypted with secp256k1 private wrapping key, re-encrypted with provided secp256k1 public transport key', type: :string
#     end

#     with_options with_example: true do
#       parameter :recovery_token, 'proof["signature"] of request used to initiate password reset (/api/v1/accounts/:id/wallets/:wallet_id/password_reset)', required: true, type: :string
#       parameter :payload, 'payload, ECIES-encrypted with secp256k1 public wrapping key (See GET PUBLIC WRAPPING KEY)', required: true, type: :integer
#       parameter :transport_public_key, 'secp256k1 public transport key in hex', required: true, type: :integer
#     end

#     subject do
#       do_request(
#         build(
#           :api_signed_request,
#           {
#             recovery_token: recovery_token,
#             payload: payload,
#             transport_public_key: transport_public_key
#           },
#           api_v1_wallet_recovery_recover_path,
#           'POST',
#           'example.org'
#         )
#       )
#     end

#     before do
#       allow_any_instance_of(Account).to receive_message_chain(:ore_id_account, :account_name).and_return(kdf_shared_info)
#       allow_any_instance_of(Account).to receive_message_chain(:ore_id_account, :schedule_password_update_sync)
#     end

#     context '201' do
#       example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY' do
#         explanation 'Returns decrypted with private wrapping key payload, re-encrypted with provided transport key'
#         result = subject
#         binding.pry
#         if status == 201
#           result[0][:request_body] = {
#                                         "recovery_token": "test_signature",
#                                         "payload": "03926854a548bfeaf27fdf9638f2ff9e9b22d1ab625d9951d020a994e556230b9c9304becff611b3b8efef50af72e9ea66289afd85f9626450",
#                                         "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917",
#                                         "body": {
#                                           "data": {
#                                             "recovery_token": "test_signature",
#                                             "payload": "03926854a548bfeaf27fdf9638f2ff9e9b22d1ab625d9951d020a994e556230b9c9304becff611b3b8efef50af72e9ea66289afd85f9626450",
#                                             "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917"
#                                           },
#                                           "url": "http://example.org/api/v1/wallet_recovery/recover",
#                                           "method": "POST",
#                                           "nonce": "ea43f7061c837ddc93007e49c06f6dba",
#                                           "timestamp": "1617607732"
#                                         },
#                                         "proof": {
#                                           "type": "Ed25519Signature2018",
#                                           "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#                                           "signature": "shaAnDXGe8arhFolJ/oWGqoZhz8gRjbptvXaNOJrTMd+CNWGiK1Imv2f/ikeLuyMuNvnIyIqs0JdkpCbMbg/Bw=="
#                                         }
#                                       }
#           result[0][:response_headers]['ETag'] = 'W/"c39a017e4bf20d3eb940e01219a72d41"'                            

#         end
#         expect(status).to eq(201)
#       end
#     end

#     context '401' do
#       let(:recovery_token) { '0' }

#       example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID RECOVERY TOKEN' do
#         explanation 'Returns array of errors'
#         result = subject
#         binding.pry
#         if status == 401
#           result[0][:request_body] = {
#                                       "recovery_token": "0",
#                                       "payload": "02f22d6598766d265d8da3dd6bdb79310b95f9cd8d541049520fca77be7fc6c38fef6b48a2ac900cd077fe9cee6ff8c24e3910789e2c9ecdb7",
#                                       "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917",
#                                       "body": {
#                                         "data": {
#                                           "recovery_token": "0",
#                                           "payload": "02f22d6598766d265d8da3dd6bdb79310b95f9cd8d541049520fca77be7fc6c38fef6b48a2ac900cd077fe9cee6ff8c24e3910789e2c9ecdb7",
#                                           "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917"
#                                         },
#                                         "url": "http://example.org/api/v1/wallet_recovery/recover",
#                                         "method": "POST",
#                                         "nonce": "e5a9a5a535bbed2eea56b14ea22f10a3",
#                                         "timestamp": "1617607732"
#                                       },
#                                       "proof": {
#                                         "type": "Ed25519Signature2018",
#                                         "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#                                         "signature": "S1Rxh0B1NYxNRFR9VzvdBYKvRqrNhPXu+dZ3yniTrnooLyyRQOii1HtTwpikn+EFKIy/VOD3eJ1NOE2QAY1rDA=="
#                                       }
#                                     }

#           result[0][:response_body] = {
#                                         "errors": {
#                                           "recoveryToken": "is invalid"
#                                         }
#                                       }
#           result[0][:response_body] = { "data": "03fc102ef4664e9d0849cc37f7f5acfe3c54f139499ae67e43e9e1f7606d922e14264be78efc76967ec6b8acb3faaa265a744987fa798cf597" }
#         end
#         expect(status).to eq(401)
#       end
#     end

#     context '401' do
#       before do
#         ApiOreIdWalletRecovery.create!(api_request_log: api_request_log)
#       end

#       example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – PREVIOUSLY USED RECOVERY TOKEN' do
#         explanation 'Returns array of errors'
#         result = subject
#         binding.pry
#         if result == 401
#           result[0][:request_body] = {
#                                       "recovery_token": "test_signature",
#                                       "payload": "022710db7e798eb820b19935ffcd6423a833600b8660b9d8696c607a6d1d11f588f8d765b5837c4395aff241da0da826e436eeac9fed3953b1",
#                                       "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917",
#                                       "body": {
#                                         "data": {
#                                           "recovery_token": "test_signature",
#                                           "payload": "022710db7e798eb820b19935ffcd6423a833600b8660b9d8696c607a6d1d11f588f8d765b5837c4395aff241da0da826e436eeac9fed3953b1",
#                                           "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917"
#                                         },
#                                         "url": "http://example.org/api/v1/wallet_recovery/recover",
#                                         "method": "POST",
#                                         "nonce": "5d1ab407c4ce880030eefe29ddca287b",
#                                         "timestamp": "1617607733"
#                                       },
#                                       "proof": {
#                                         "type": "Ed25519Signature2018",
#                                         "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#                                         "signature": "Nijjftr5A7PZvo/J658BH8Dpzzz+f2h+bKBp1tIifa9AdqPBkVZi0hI8IXFqSRzHqZuX9Xsb77CZbBhrPqa/DQ=="
#                                       }
#                                     }

#           result[0][:response_body] = {
#                                         "errors": {
#                                           "recoveryToken": "is invalid"
#                                         }
#                                       }           
#         end
#         expect(status).to eq(401)
#       end
#     end

#     context '400' do
#       let(:payload) { '0' }

#       example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID PAYLOAD' do
#         explanation 'Returns array of errors'
#         result = subject
#          binding.pry
#         if status == 400
#          binding.pry
#         end
#         expect(status).to eq(400)
#       end
#     end

#     context '400' do
#       let(:transport_public_key) { '' }

#       example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID TRANSPORT PUBLIC KEY' do
#         explanation 'Returns array of errors'
#         result = subject
#         binding.pry
#         if status == 400
#           result[0][:request_body] = {
#                                         "recovery_token": "test_signature",
#                                         "payload": "02ff36c44c64407b47165de812bcbb7221f9196ca6fb3c89c84de1332f379d7e9084c79b97acac64b0a6bf20eb2313eab19c657aa479195b90",
#                                         "transport_public_key": "",
#                                         "body": {
#                                           "data": {
#                                             "recovery_token": "test_signature",
#                                             "payload": "02ff36c44c64407b47165de812bcbb7221f9196ca6fb3c89c84de1332f379d7e9084c79b97acac64b0a6bf20eb2313eab19c657aa479195b90",
#                                             "transport_public_key": ""
#                                           },
#                                           "url": "http://example.org/api/v1/wallet_recovery/recover",
#                                           "method": "POST",
#                                           "nonce": "eaf65a77fe2bad8db6fb23c59d06e9f1",
#                                           "timestamp": "1617607731"
#                                         },
#                                         "proof": {
#                                           "type": "Ed25519Signature2018",
#                                           "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#                                           "signature": "GECxYc0IJTsZH3BkWOPegdA8WiKJwufFwmvzmC8EcHRiwQ5S1beaY/OmwocSqCBsiiVfandrVt1tF0YnOrXADw=="
#                                         }
#                                       }

#           result[0][:response_body] = {
#                                         "errors": {
#                                           "payload": "cannot be processed"
#                                         }
#                                       }                            
#         end  
#         expect(status).to eq(400)
#       end
#     end
#   end
# end
