require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'XI. Wallet Recovery' do
  include Rails.application.routes.url_helpers

  before do
    Timecop.freeze(Time.zone.local(2021, 4, 6, 10, 5, 0))
    allow_any_instance_of(Comakery::APISignature).to receive(:nonce).and_return('0242d70898bcf3fbb5fa334d1d87804f')
  end

  after do
    Timecop.return
  end

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: nil, wallet_recovery_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:static_account, id: 62, managed_mission: active_whitelabel_mission) }
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
        result[0][:response_headers]['ETag'] = 'W/"4e8d0fe4422ce938bb88f3f3a5be2c81"' if status == 200
        expect(status).to eq(200)
      end
    end

    context '500' do
      let(:private_wrapping_key) { '' }

      example 'GET PUBLIC WRAPPING KEY – ERROR' do
        explanation 'Returns array of errors'
        subject
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

    let(:payload) { '02a308cf11cdbbd2116d3ab7b3471e55a95a515e324f48b1b713ddfedcbb65fc5db860c3c4d1e917b3cdabf10a7c5e9ce1567ba22ac8dfc14a' }

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
          result[0][:response_headers]['ETag'] = 'W/"c69412922fec0b6b3bc0ff9e1c207199"'
          body = JSON.parse(result[0][:response_body])
          body['data'] = '03d71a3bdc5b609f2845744904aa1fb5f4a62a742aa5d8d221cc9e2d21601f4c5447f85aa71d4a1c7b8a075cf3f7f529093be13531f6457e14'
          result[0][:response_body] = body.to_json
        end
        expect(status).to eq(201)
      end
    end

    context '401' do
      let(:recovery_token) { '0' }

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID RECOVERY TOKEN' do
        explanation 'Returns array of errors'
        subject
        expect(status).to eq(401)
      end
    end

    context '401' do
      before do
        ApiOreIdWalletRecovery.create!(api_request_log: api_request_log)
      end

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – PREVIOUSLY USED RECOVERY TOKEN' do
        explanation 'Returns array of errors'
        subject
        expect(status).to eq(401)
      end
    end

    context '400' do
      let(:payload) { '0' }

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID PAYLOAD' do
        explanation 'Returns array of errors'
        subject
        expect(status).to eq(400)
      end
    end

    context '400' do
      let(:transport_public_key) { '' }

      example 'RECOVER DATA ENCRYPTED WITH PUBLIC WRAPPING KEY – INVALID TRANSPORT PUBLIC KEY' do
        explanation 'Returns array of errors'
        subject
        expect(status).to eq(400)
      end
    end
  end
end
