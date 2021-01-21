require 'rails_helper'

RSpec.describe Api::V1::WalletRecoveryController, type: :controller do
  describe 'GET /public_wrapping_key' do
    render_views

    context 'with correct private key' do
      # To check you can use https://gobittest.appspot.com/Address
      it 'renders a successful response' do
        allow(ENV).to receive(:[]).with('WALLET_RECOVERY_WRAPPING_KEY').and_return('18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725')
        get :public_wrapping_key
        expect(response).to be_successful
        expect(response.body).to eq '{"public_wrapping_key":"0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6"}'
      end
    end

    context 'with incorrect private key' do
      specify 'when private key is nil it renders an error' do
        allow(ENV).to receive(:[]).with('WALLET_RECOVERY_WRAPPING_KEY').and_return(nil)
        get :public_wrapping_key
        expect(response.status).to eq 500
        expect(response.body).to eq '{"errors":{"invalid_env_variable":"WALLET_RECOVERY_WRAPPING_KEY variable was not configured or use wrong format"}}'
      end

      specify 'when private key is blank string it renders an error' do
        allow(ENV).to receive(:[]).with('WALLET_RECOVERY_WRAPPING_KEY').and_return('')
        get :public_wrapping_key
        expect(response.status).to eq 500
        expect(response.body).to eq '{"errors":{"invalid_env_variable":"WALLET_RECOVERY_WRAPPING_KEY variable was not configured or use wrong format"}}'
      end

      specify 'when private key in wrong format it renders an error' do
        allow(ENV).to receive(:[]).with('WALLET_RECOVERY_WRAPPING_KEY').and_return('some_invalid_key')
        get :public_wrapping_key
        expect(response.status).to eq 500
        expect(response.body).to eq '{"errors":{"invalid_env_variable":"WALLET_RECOVERY_WRAPPING_KEY variable was not configured or use wrong format"}}'
      end
    end
  end
end
