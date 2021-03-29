require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_recovery_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::WalletRecoveryController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_recovery_signature'
  it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_api_public_key: nil, wallet_recovery_api_public_key: build(:api_public_key), whitelabel_domain: 'test.host', whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  # To check you can use https://gobittest.appspot.com/Address
  let(:private_wrapping_key) { '18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725' }
  let(:public_wrapping_key) { '0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6' }

  before do
    allow(controller).to receive(:authorized).and_return(true)
    allow(ENV).to receive(:fetch).with('WALLET_RECOVERY_WRAPPING_KEY', 'default_key').and_return(private_wrapping_key)
  end

  describe 'GET #public_wrapping_key' do
    render_views

    subject do
      params = build(
        :api_signed_request,
        '',
        api_v1_wallet_recovery_public_wrapping_key_path,
        'GET'
      )

      get :public_wrapping_key, params: params
    end

    context 'with incorrect private_wrapping_key' do
      context 'which is blank' do
        let(:private_wrapping_key) { '' }
        it { is_expected.to have_http_status(:internal_server_error) }

        it 'renders an error' do
          subject
          expect(response.body).to eq '{"errors":{"wrapping_key_private":"is invalid"}}'
        end
      end

      context 'which is in wrong format' do
        let(:private_wrapping_key) { '0' }
        it { is_expected.to have_http_status(:internal_server_error) }

        it 'renders an error' do
          subject
          expect(response.body).to eq '{"errors":{"wrapping_key_private":"is invalid"}}'
        end
      end
    end

    context 'with correct private key' do
      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('api/v1/wallet_recovery/public_wrapping_key.json') }

      it 'renders public_wrapping_key' do
        subject

        expect(response.body).to eq "{\"public_wrapping_key\":\"#{public_wrapping_key}\"}"
      end
    end
  end

  describe 'POST #recover' do
    render_views

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

    subject do
      params = build(
        :api_signed_request,
        {
          recovery_token: recovery_token,
          payload: payload,
          transport_public_key: transport_public_key
        },
        api_v1_wallet_recovery_recover_path,
        'POST'
      )

      post :recover, params: params
    end

    before do
      allow_any_instance_of(Account).to receive_message_chain(:ore_id_account, :account_name).and_return(kdf_shared_info)
      allow_any_instance_of(Account).to receive_message_chain(:ore_id_account, :schedule_password_update_sync)
    end

    context 'with invalid recovery_token' do
      let(:recovery_token) { '0' }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with expired recovery_token' do
      let(:api_request_log) { create(:api_request_log, created_at: DateTime.current - 10.minutes) }
      let(:recovery_token) { api_request_log.signature }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with recovery_token associated with a request without account_id' do
      let(:api_request_log) { create(:api_request_log) }
      let(:recovery_token) { api_request_log.signature }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with valid recovery_token' do
      context 'which already has been used' do
        before do
          ApiOreIdWalletRecovery.create!(api_request_log: api_request_log)
        end

        it { is_expected.to have_http_status(:unauthorized) }
      end

      context 'which has not been used yet' do
        context 'and invalid payload' do
          let(:payload) { '0' }

          it { is_expected.to have_http_status(:bad_request) }
        end

        context 'and valid payload' do
          context 'with incorrect private wrapping key' do
            let(:private_wrapping_key) { '0' }

            it { is_expected.to have_http_status(:bad_request) }
          end

          context 'and corrent private wrapping key' do
            context 'and incorrect transport public key' do
              let(:transport_public_key) { '' }

              it { is_expected.to have_http_status(:bad_request) }
            end

            context 'and correct transport public key' do
              context 'and payload encnrypted for a wrong OreIdAccount' do
                before do
                  allow_any_instance_of(Account).to receive_message_chain(:ore_id_account, :account_name).and_return('differentoreidaccountname')
                end

                it { is_expected.to have_http_status(:bad_request) }
              end

              context 'and payload encnrypted for correct OreIdAccount' do
                it { is_expected.to have_http_status(:created) }
                it { is_expected.to render_template('api/v1/data.json') }

                it 'returns decrypted with private wrapping key and oreId accountName as kdf_shared_info payload, reenncrypted with transport key' do
                  subject

                  data = JSON.parse(response.body)['data']

                  expect(
                    ECIES::Crypt.new.decrypt(
                      ECIES::Crypt.private_key_from_hex(transport_private_key),
                      [data].pack('H*')
                    )
                  ).to eq(original_message)
                end

                it 'schedules password update sync' do
                  allow_any_instance_of(Account).to receive(:ore_id_account).and_return(create(:ore_id, skip_jobs: true))
                  expect_any_instance_of(OreIdAccount).to receive(:schedule_password_update_sync)

                  subject
                end
              end
            end
          end
        end
      end
    end
  end
end
