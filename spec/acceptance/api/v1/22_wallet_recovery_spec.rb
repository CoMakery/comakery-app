require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'XI. Wallet Recovery' do
  include Rails.application.routes.url_helpers

  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: nil, wallet_recovery_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let(:private_wrapping_key) { '18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725' }
  let(:public_wrapping_key) { '0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6' }

  explanation 'Recover data, which was ECIES-encrypted with provided secp256k1 public key. Please use wallet recovery private key to sign requests.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  before do
    allow(ENV).to receive(:fetch).with('WALLET_RECOVERY_WRAPPING_KEY', 'default_key').and_return(private_wrapping_key)
  end

  get '/api/v1/wallet_recovery/public_wrapping_key' do
    subject do
      do_request(
        build(
          :api_signed_request,
          '',
          api_v1_wallet_recovery_public_wrapping_key_path,
          'GET',
          'example.org'
        )
      )
    end

    with_options with_example: true do
      response_field :public_wrapping_key, 'secp256k1 public wrapping key in hex', type: :string
    end

    context '200' do
      example 'GET PUBLIC WRAPPING KEY' do
        explanation 'Returns a public wrapping key.'
        result = subject
        if status == 200
          result[0][:request_path] = '/api/v1/wallet_recovery/public_wrapping_key?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fwallet_recovery%2Fpublic_wrapping_key&body[method]=GET&body[nonce]=6f11c288300780f6b30cc310532f39e3&body[timestamp]=1617707687&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=%2BqyCyXLJHdjenY4qZfFB8uGUoiq6VpnG%2BkZJKi2ArV6QOTbX8HMgCX0WnDCCDdhZwJIuOaC5r%2BCjKHE28jxGAQ%3D%3D'
          result[0][:request_query_parameters] = { body: {"data"=>"", "url"=>"http://example.org/api/v1/wallet_recovery/public_wrapping_key", "method"=>"GET", "nonce"=>"6f11c288300780f6b30cc310532f39e3", "timestamp"=>"1617707687"},
                                                   proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"+qyCyXLJHdjenY4qZfFB8uGUoiq6VpnG+kZJKi2ArV6QOTbX8HMgCX0WnDCCDdhZwJIuOaC5r+CjKHE28jxGAQ=="}
                                                 }

          result[0][:response_headers]['ETag'] = 'W/"4e8d0fe4422ce938bb88f3f3a5be2c81"'
          result[0][:response_body] = { "publicWrappingKey": "0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6" }
        end
        expect(status).to eq(200)
      end
    end

    context '500' do
      let(:private_wrapping_key) { '' }

      example 'GET PUBLIC WRAPPING KEY – ERROR' do
        explanation 'Returns array of errors'
        result = subject
        if status == 500
          result[0][:request_path] = '/api/v1/wallet_recovery/public_wrapping_key?body[data]=&body[url]=http%3A%2F%2Fexample.org%2Fapi%2Fv1%2Fwallet_recovery%2Fpublic_wrapping_key&body[method]=GET&body[nonce]=5adeaf72b22104c472e3f23cff54824d&body[timestamp]=1617707687&proof[type]=Ed25519Signature2018&proof[verificationMethod]=O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi%2FzgVCVpA%3D&proof[signature]=u9OOygqa3vu%2FHpRGHtZ29HrPrKyXn%2FHO99aG1%2BrM4dOAxGhm%2BV5DB2DzSudYh6MWpzo4%2BZWII7WTkbgX2TmjDA%3D%3D'
          result[0][:request_query_parameters] = {body: {"data"=>"", "url"=>"http://example.org/api/v1/wallet_recovery/public_wrapping_key", "method"=>"GET", "nonce"=>"5adeaf72b22104c472e3f23cff54824d", "timestamp"=>"1617707687"},
                                                  proof: {"type"=>"Ed25519Signature2018", "verificationMethod"=>"O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=", "signature"=>"u9OOygqa3vu/HpRGHtZ29HrPrKyXn/HO99aG1+rM4dOAxGhm+V5DB2DzSudYh6MWpzo4+ZWII7WTkbgX2TmjDA=="}
                                                }                                    
        end
        expect(status).to eq(500)
      end
    end
  end

  post '/api/v1/wallet_recovery/recover' do
    let(:api_request_log) { create(:api_request_log, body: { 'account_id' => account.managed_account_id }) }
    let(:recovery_token) { api_request_log.signature }
    let(:transport_public_key) { '048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917' }
    let(:transport_private_key) { 'ADE3E0761CEB242A1BE92043825CD7C677A9A7E25C31F05F4D88DF4D13E2919C' }
    let(:kdf_shared_info) { 'dummyoreidaccountname' }
    let(:original_message) { 'Hello :)' }

    let(:payload) do
      ECIES::Crypt.new(
        kdf_shared_info: kdf_shared_info
      ).encrypt(
        ECIES::Crypt.public_key_from_hex(public_wrapping_key),
        original_message
      ).unpack1('H*')
    end

    with_options with_example: true do
      response_field :data, 'payload, ECIES-decrypted with secp256k1 private wrapping key, re-encrypted with provided secp256k1 public transport key', type: :string
    end

    with_options with_example: true do
      parameter :recovery_token, 'proof["signature"] of request used to initiate password reset (/api/v1/accounts/:id/wallets/:wallet_id/password_reset)', required: true, type: :string
      parameter :payload, 'payload, ECIES-encrypted with secp256k1 public wrapping key (See GET PUBLIC WRAPPING KEY)', required: true, type: :integer
      parameter :transport_public_key, 'secp256k1 public transport key in hex', required: true, type: :integer
    end

    subject do
      do_request(
        build(
          :api_signed_request,
          {
            recovery_token: recovery_token,
            payload: payload,
            transport_public_key: transport_public_key
          },
          api_v1_wallet_recovery_recover_path,
          'POST',
          'example.org'
        )
      )
    end

    before do
      allow_any_instance_of(Account).to receive_message_chain(:ore_id_account, :account_name).and_return(kdf_shared_info)
      allow_any_instance_of(Account).to receive_message_chain(:ore_id_account, :schedule_password_update_sync)
    end

    context '201' do
      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY' do
        explanation 'Returns decrypted with private wrapping key payload, re-encrypted with provided transport key'
        result = subject
        if status == 201
          result[0][:request_body] = {
                                        "recovery_token": "test_signature",
                                        "payload": "034cd8a93f5de5faf91fdaa2fc676b6fca8000730a32a1543e9ef362c8652dafefbf82252e39fcba16788c95470e66410980f91dbf3f52ad66",
                                        "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917",
                                        "body": {
                                          "data": {
                                            "recovery_token": "test_signature",
                                            "payload": "034cd8a93f5de5faf91fdaa2fc676b6fca8000730a32a1543e9ef362c8652dafefbf82252e39fcba16788c95470e66410980f91dbf3f52ad66",
                                            "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917"
                                          },
                                          "url": "http://example.org/api/v1/wallet_recovery/recover",
                                          "method": "POST",
                                          "nonce": "b7e0afd4ae50a950f8ad2630fe29c4e9",
                                          "timestamp": "1617707688"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "KqVOw/z5HvNWx4GeFHFIA4erT4rV7oMyuSGDHkeQ9xBm8ybs4ZLuWjma/CXKYJ4CiLZuXYSqL3wng+jNcuT0Bw=="
                                        }
                                      }
          result[0][:response_headers]['ETag'] = 'W/"c69412922fec0b6b3bc0ff9e1c207199"'
          result[0][:response_body] = { "data": "024d1e934848f67268ca90a0f5fc0ca70d969a998bcf66adfefacf398720f0f1e04f0ea677fec6e5de9f13c723f001a94e1b33b8ae845f7de1" }
        end
        expect(status).to eq(201)
      end
    end

    context '401' do
      let(:recovery_token) { '0' }

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID RECOVERY TOKEN' do
        explanation 'Returns array of errors'
        result = subject
        if status == 401
          result[0][:request_body] = {
                                        "recovery_token": "0",
                                        "payload": "0340f15e73d4ee4908857ac84cf9dbd220d04a24e1832cc8c9eaa6476119935e3eaf0456c92de64bf26a462de65185b87a45a4cf8631f630f0",
                                        "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917",
                                        "body": {
                                          "data": {
                                            "recovery_token": "0",
                                            "payload": "0340f15e73d4ee4908857ac84cf9dbd220d04a24e1832cc8c9eaa6476119935e3eaf0456c92de64bf26a462de65185b87a45a4cf8631f630f0",
                                            "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917"
                                          },
                                          "url": "http://example.org/api/v1/wallet_recovery/recover",
                                          "method": "POST",
                                          "nonce": "02764da99f14cfea6a760d49f6974005",
                                          "timestamp": "1617707689"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "lQoHFi+BaK7uMDW6tOZYXEB1NUKNSjOXu5+KM8cAesNyR5zU0HUDMFIM3b21wvAIdt5HkBQbrMseyBhTqR9CDg=="
                                        }
                                      }
        end
        expect(status).to eq(401)
      end
    end

    context '401' do
      before do
        ApiOreIdWalletRecovery.create!(api_request_log: api_request_log)
      end

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – PREVIOUSLY USED RECOVERY TOKEN' do
        explanation 'Returns array of errors'
        result = subject
        if result == 401
          result[0][:request_body] = {
                                        "recovery_token": "test_signature",
                                        "payload": "02c2f21718cb93acab511dadc47e5d9591c5e0888d3771ff0d6122bdd29d0a26afff3f838fdb3f24c253354d14c6ba6f1cfca0e0202870fcbd",
                                        "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917",
                                        "body": {
                                          "data": {
                                            "recovery_token": "test_signature",
                                            "payload": "02c2f21718cb93acab511dadc47e5d9591c5e0888d3771ff0d6122bdd29d0a26afff3f838fdb3f24c253354d14c6ba6f1cfca0e0202870fcbd",
                                            "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917"
                                          },
                                          "url": "http://example.org/api/v1/wallet_recovery/recover",
                                          "method": "POST",
                                          "nonce": "34832da5630cdf4e8a616d517b92f2a3",
                                          "timestamp": "1617707688"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "9w3Zp0aSG3NXeezBKsBUs+8idYFkkQAkGwH3MkYR/UdYX31q4n6pfAFPvEtd1eh2Q5j502cubuOPp08wjUf3Ag=="
                                        }
                                      }       
        end
        expect(status).to eq(401)
      end
    end

    context '400' do
      let(:payload) { '0' }

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID PAYLOAD' do
        explanation 'Returns array of errors'
        result = subject
        if status == 400
          result[0][:request_body] = {
                                        "recovery_token": "test_signature",
                                        "payload": "0",
                                        "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917",
                                        "body": {
                                          "data": {
                                            "recovery_token": "test_signature",
                                            "payload": "0",
                                            "transport_public_key": "048F5ED4C1BE651F6254F22FFD41CE963CCD7A0BA36CF57E8AB56C17D0CCBDD572BDB242E30FE01AE4040D6F8F76425D2C05EA82FE14804F08E266E017A6D3E917"
                                          },
                                          "url": "http://example.org/api/v1/wallet_recovery/recover",
                                          "method": "POST",
                                          "nonce": "75b561ab129901ed953daa1c2ae8aa27",
                                          "timestamp": "1617707688"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "rrHZSDr4tetHwjRgnsdr0kJftcX7gNuvNFy6HUm9Hc0rwgJ44qzWHtJZycyBvt16yaEK45UoQkHeuns5OoT+Bw=="
                                        }
                                      }
        end
        expect(status).to eq(400)
      end
    end

    context '400' do
      let(:transport_public_key) { '' }

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID TRANSPORT PUBLIC KEY' do
        explanation 'Returns array of errors'
        result = subject
        if status == 400
          result[0][:request_body] = {
                                        "recovery_token": "test_signature",
                                        "payload": "02069206221e5129a9a37f6b51acce0a45cf624fdf0379e19cf11b030c46320705ef98ad503019dc904202d43c62179e08477db312d062ad07",
                                        "transport_public_key": "",
                                        "body": {
                                          "data": {
                                            "recovery_token": "test_signature",
                                            "payload": "02069206221e5129a9a37f6b51acce0a45cf624fdf0379e19cf11b030c46320705ef98ad503019dc904202d43c62179e08477db312d062ad07",
                                            "transport_public_key": ""
                                          },
                                          "url": "http://example.org/api/v1/wallet_recovery/recover",
                                          "method": "POST",
                                          "nonce": "d08e1ffc5a85d4fdd7ac805b6a976a8b",
                                          "timestamp": "1617707689"
                                        },
                                        "proof": {
                                          "type": "Ed25519Signature2018",
                                          "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
                                          "signature": "Q3GZyGwXvMxz0RDM2jORpWfQi4l8D6rXLfMsQrke8vyOkyH78WTdM12n98vmdSZBL9I57dqQCGbkd/843oM5CA=="
                                        }
                                      }                 
        end
        expect(status).to eq(400)
      end
    end
  end
end
