require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::WalletRecoveryController, type: :controller do
  # TODO: Fix lines below
  # it_behaves_like 'requires_an_authorization'
  # it_behaves_like 'requires_signature'
  # it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  describe 'GET /public_wrapping_key' do
    render_views

    let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
    # let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

    subject do
      params = build(:api_signed_request, '', api_v1_wallet_recovery_public_wrapping_key_path, 'GET')
      get :public_wrapping_key, params: params
    end

    before do
      allow(controller).to receive(:authorized).and_return(true)
    end

    context 'with correct private key' do
      # To check you can use https://gobittest.appspot.com/Address
      it 'renders a successful response' do
        allow(ENV).to receive(:fetch).with('WALLET_RECOVERY_WRAPPING_KEY', 'default_key').and_return('18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725')

        subject

        expect(response).to be_successful
        expect(response.body).to eq '{"public_wrapping_key":"0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6"}'
      end
    end

    context 'with incorrect private key' do
      specify 'when private key is blank string it renders an error' do
        allow(ENV).to receive(:fetch).with('WALLET_RECOVERY_WRAPPING_KEY', 'default_key').and_return('')

        subject

        expect(response.status).to eq 500
        expect(response.body).to eq '{"errors":{"invalid_env_variable":"WALLET_RECOVERY_WRAPPING_KEY variable was not configured or use wrong format"}}'
      end

      specify 'when private key in wrong format it renders an error' do
        allow(ENV).to receive(:fetch).with('WALLET_RECOVERY_WRAPPING_KEY', 'default_key').and_return('some_invalid_key')

        subject

        expect(response.status).to eq 500
        expect(response.body).to eq '{"errors":{"invalid_env_variable":"WALLET_RECOVERY_WRAPPING_KEY variable was not configured or use wrong format"}}'
      end
    end
  end
end
