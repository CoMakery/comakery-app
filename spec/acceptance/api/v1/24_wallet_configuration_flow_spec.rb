require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'XIII. Full Wallet configurations flow' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, account: account) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  explanation <<~TEXT
    1. Create a comakery account
    2. Create ORE ID wallets
    3. Get password reset link for ETH ORE ID wallet created
    4. Redirect the user to ORE ID reset URL get from step 3
  TEXT

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  post '/api/v1/accounts' do
    example '1. Create a comakery account' do
      explanation 'Returns created account data'

      # 1. Create a comakery account
      account_params = { managed_account_id: SecureRandom.uuid, email: "me+#{SecureRandom.hex(20)}@example.com", first_name: 'Eva', last_name: 'Smith', nickname: "hunter-#{SecureRandom.hex(20)}", date_of_birth: '1990-01-31', country: 'United States of America' }
      request = build(:api_signed_request, { account: account_params }, api_v1_accounts_path, 'POST', 'example.org')
      result = do_request(request)
      if status == 201
        result[0][:request_body] = {
          "body": {
            "data": {
              "account": {
                "managed_account_id": 'bfca35b9-6c9b-449f-93b6-16f2d064de7d',
                "email": 'me+e83af0061f6e2a3345ea55c516c9cef3bb788ba7@example.com',
                "first_name": 'Eva',
                "last_name": 'Smith',
                "nickname": 'hunter-462b87f9e0d6e2149911a619a76116f1f0c820de',
                "date_of_birth": '1990-01-31',
                "country": 'United States of America'
              }
            },
            "url": 'http://example.org/api/v1/accounts',
            "method": 'POST',
            "nonce": 'cee363fdf70e7739e7f5fe9ef9048767',
            "timestamp": '1617607755'
          },
          "proof": {
            "type": 'Ed25519Signature2018',
            "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
            "signature": 'N7NbGXFoV2D5afgW9ylUCKZT7EAHhLtBSW/ylWl4Z0/Gm39Hp5ljzagrxxVjj8uGLuBUVhzJUu31EAMk1naSAA=='
          }
        }
        result[0][:response_headers]['ETag'] = 'W/"95ef9c4dc49ce85d83f168bdb02e069e"'
        result[0][:response_body] = {
          "email": 'me+e83af0061f6e2a3345ea55c516c9cef3bb788ba7@example.com',
          "managedAccountId": 'bfca35b9-6c9b-449f-93b6-16f2d064de7d',
          "firstName": 'Eva',
          "lastName": 'Smith',
          "nickname": 'hunter-462b87f9e0d6e2149911a619a76116f1f0c820de',
          "imageUrl": 'http://example.org/assets/default_account_image-eee1531b23fb9820d114c626a7e4212a9c54f7cf8522720d6ba1454787299a53.jpg',
          "country": 'United States of America',
          "dateOfBirth": '1990-01-31',
          "verificationState": 'unknown',
          "verificationDate": nil,
          "verificationMaxInvestmentUsd": nil,
          "createdAt": '2021-04-05T07:29:15.363Z',
          "updatedAt": '2021-04-05T07:29:15.363Z'
        }
      end
      expect(status).to eq(201)
    end
  end

  post '/api/v1/accounts/:id/wallets' do
    let!(:id) { account.managed_account_id }
    let!(:create_params) { { wallets: [{ blockchain: :ethereum, address: build(:ethereum_address_1), name: 'ETH Wallet' }] } }

    example '2. Create ORE ID wallets' do
      explanation 'Returns created wallets'

      request = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST', 'example.org')
      result = do_request(request)
      if status == 201
        result[0][:request_path] = '/api/v1/accounts/43ff3e88-f722-4cc3-a438-56605f3e4580/wallets'
        result[0][:request_body] = {
          "body": {
            "data": {
              "wallets": [
                {
                  "blockchain": 'ethereum',
                  "address": '0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB',
                  "name": 'ETH Wallet'
                }
              ]
            },
            "url": 'http://example.org/api/v1/accounts/43ff3e88-f722-4cc3-a438-56605f3e4580/wallets',
            "method": 'POST',
            "nonce": '6f8765163d21648394d48ec70d388d07',
            "timestamp": '1617607756'
          },
          "proof": {
            "type": 'Ed25519Signature2018',
            "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
            "signature": '0H+YG9LZT9KLNlJnt1cf3F0TgI92WujHrLwq4UmR3fC01xy9/yKsTRyB1nT9cEhemWBc1XGFaX3aISnoboo0CQ=='
          }
        }
        result[0][:response_headers]['ETag'] = 'W/"97e5d587f425581b396c77a4343ee5b9"'
        result[0][:response_body] = [
          {
            "id": 19,
            "name": 'ETH Wallet',
            "address": '0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB',
            "primaryWallet": true,
            "source": 'user_provided',
            "state": 'ok',
            "createdAt": '2021-04-05T07:29:16.339Z',
            "updatedAt": '2021-04-05T07:29:16.339Z',
            "blockchain": 'ethereum',
            "provisionTokens": []
          }
        ]
      end
      expect(status).to eq(201)
    end
  end

  post '/api/v1/accounts/:id/wallets/:wallet_id/password_reset' do
    let!(:id) { account.managed_account_id }
    let!(:wallet_id) { create(:ore_id_wallet, account: account).id.to_s }
    let!(:redirect_url) { 'localhost' }

    example '3. Get password reset link for ETH ORE ID wallet created' do
      explanation 'Returns reset password url for wallet'

      request = build(:api_signed_request, { redirect_url: redirect_url }, password_reset_api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet_id), 'POST', 'example.org')

      allow_any_instance_of(OreIdService).to receive(:create_token).and_return('dummy_token')
      allow_any_instance_of(OreIdService).to receive(:remote).and_return({ 'email' => account.email })
      result = do_request(request)
      if status == 200
        result[0][:request_path] = '/api/v1/accounts/aa3fe785-0d95-4613-a432-23aa229553b5/wallets/1/password_reset'
        result[0][:request_body] = { "body": {
          "data": {
            "redirect_url": 'localhost'
          },
          "url": 'http://example.org/api/v1/accounts/3ee52dd6-4308-47cb-b7a9-c27dce43973d/wallets/20/password_reset',
          "method": 'POST',
          "nonce": '2255ce7265779fbb7652e8ac6e30d7ba',
          "timestamp": '1617607757'
        },
                                     "proof": {
                                       "type": 'Ed25519Signature2018',
                                       "verificationMethod": 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=',
                                       "signature": 'QyClowWJjEem6Yb/O9Ut3PEVePr5CHnnBjHy2Q03vNeDYsmlZAxaOADLbDcs/KP3dx44Soj3NUlXc9+lQFoTCA=='
                                     } }
        result[0][:response_headers]['ETag'] = 'W/"518f5242330553c6b7e88c28c2a2bc42"'
        result[0][:response_body] = { "resetUrl": 'https://service.oreid.io/recover-account?account=&app_access_token=dummy_token&background_color=FFFFFF&callback_url=localhost&email=me%2Be333ddf3cc5cf4e70f43ed72287c0fa60dc7095f%40example.com&provider=email&recover_action=republic&state=&hmac=VeDMqWpK%2FnvybgoG223phTpBYgbd9zesFe%2Bh7lE7Rq4%3D' }
      end
      expect(status).to eq(200)
    end
  end
end
