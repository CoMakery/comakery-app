require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::WalletsController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_signature'
  it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'GET #index' do
    it 'returns account wallets' do
      params = build(:api_signed_request, '', api_v1_account_wallets_path(account_id: account.managed_account_id), 'GET')
      params[:account_id] = account.managed_account_id
      params[:format] = :json

      get :index, params: params
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_account_wallets_path(account_id: account.managed_account_id), 'GET')
      params.merge!(account_id: account.managed_account_id, format: :json, page: 9999)

      get :index, params: params
      expect(response).to be_successful
      expect(assigns[:wallets]).to eq([])
    end
  end

  describe 'POST #create' do
    render_views
    let(:create_params) { { wallet: { blockchain: :bitcoin, address: build(:bitcoin_address_1) } } }

    context 'with valid params' do
      it 'adds wallet to requested account' do
        expect do
          params = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
          params[:account_id] = account.managed_account_id

          post :create, params: params
        end.to change(account.wallets, :count).by(1)
      end

      it 'returns created wallet' do
        params = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params
        expect(response).to have_http_status(:created)
      end

      it 'creates a provisioned wallet' do
        token = create(:asa_token)
        ore_id_params = { wallet: { blockchain: :algorand_test, source: 'ore_id', tokens_to_provision: "[#{token.id}]" } }
        params = build(:api_signed_request, ore_id_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params
        expect(response).to have_http_status(:created)

        wallet = Wallet.last
        expect(wallet._blockchain).to eq 'algorand_test'
        expect(wallet.source).to eq 'ore_id'

        provision = WalletProvision.last
        expect(provision.wallet).to eq wallet
        expect(provision.token).to eq token
        expect(provision.state).to eq 'pending'
      end
    end

    context 'with invalid params' do
      before do
        account.wallets.create(_blockchain: :bitcoin, address: build(:bitcoin_address_1))
      end

      it 'renders an error' do
        params = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end

      context 'with unknown blockchain' do
        let(:create_params) { { wallet: { blockchain: :unknown, address: build(:bitcoin_address_1) } } }

        it 'renders an error' do
          params = build(:api_signed_request, create_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
          params[:account_id] = account.managed_account_id

          post :create, params: params
          expect(response).not_to be_successful
          expect(response).to have_http_status(400)
          expect(assigns[:errors][:_blockchain]).to eq ['unknown blockchain value']
        end
      end

      it 'with wrong formated and JSON valid tokens_to_provision param' do
        ore_id_params = { wallet: { blockchain: :algorand_test, source: 'ore_id', tokens_to_provision: '1' } }
        params = build(:api_signed_request, ore_id_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq '{"errors":{"tokens_to_provision":["Wrong format. It must be an Array. For example: [1,5]"]}}'
        expect(Wallet.where(_blockchain: :algorand_test).count).to be_zero
      end

      it 'with wrong formated and JSON invalid tokens_to_provision param' do
        ore_id_params = { wallet: { blockchain: :algorand_test, source: 'ore_id', tokens_to_provision: '[1' } }
        params = build(:api_signed_request, ore_id_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq '{"errors":{"tokens_to_provision":["Wrong format. It must be an Array. For example: [1,5]"]}}'
        expect(Wallet.where(_blockchain: :algorand_test).count).to be_zero
      end

      it 'with unknown tokens_to_provision param' do
        ore_id_params = { wallet: { blockchain: :algorand_test, source: 'ore_id', tokens_to_provision: '[9999]' } }
        params = build(:api_signed_request, ore_id_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq '{"errors":{"tokens_to_provision":["Unknown token ids: [9999]"]}}'
        expect(Wallet.where(_blockchain: :algorand_test).count).to be_zero
      end

      it 'tokens_to_provision with token which can not be provisioned' do
        token = create(:token)
        ore_id_params = { wallet: { blockchain: :algorand_test, source: 'ore_id', tokens_to_provision: "[#{token.id}]" } }
        params = build(:api_signed_request, ore_id_params, api_v1_account_wallets_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq "{\"errors\":{\"tokens_to_provision\":[\"Some tokens can't be provisioned: [#{token.id}]\"]}}"
        expect(Wallet.where(_blockchain: :algorand_test).count).to be_zero
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      let!(:wallet) { account.wallets.create(_blockchain: :bitcoin, address: build(:bitcoin_address_1)) }

      it 'removes the wallet from the requested account' do
        expect do
          params = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet.id.to_s), 'DELETE')
          params[:account_id] = account.managed_account_id
          params[:id] = wallet.id

          delete :destroy, params: params
        end.to change(account.wallets, :count).by(-1)
      end

      it 'returns list of account wallets' do
        params = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet.id.to_s), 'DELETE')
        params[:account_id] = account.managed_account_id
        params[:id] = wallet.id

        delete :destroy, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when wallet cannot be destroyed' do
      subject { create(:wallet, account: account, source: :ore_id) }

      it 'renders an error' do
        params = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: subject.id.to_s), 'DELETE')
        params[:account_id] = account.managed_account_id
        params[:id] = subject.id

        delete :destroy, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'GET #show' do
    context 'with valid params' do
      let!(:wallet) { account.wallets.create(_blockchain: :bitcoin, address: build(:bitcoin_address_1)) }

      it 'returns the wallet' do
        params = build(:api_signed_request, '', api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet.id.to_s), 'GET')
        params[:account_id] = account.managed_account_id
        params[:id] = wallet.id
        params[:format] = :json

        get :show, params: params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST #password_reset' do
    context 'with valid params' do
      render_views
      let!(:wallet) { account.wallets.create(_blockchain: :bitcoin, address: build(:bitcoin_address_1), source: :ore_id) }

      it 'returns url for password reset and scedules a job for password' do
        params = build(:api_signed_request, { redirect_url: 'https://localhost' }, password_reset_api_v1_account_wallet_path(account_id: account.managed_account_id, id: wallet.id.to_s), 'POST')
        params[:account_id] = account.managed_account_id
        params[:id] = wallet.id

        allow_any_instance_of(OreIdService).to receive(:create_token).and_return('dummy_token')

        expect(OreIdPasswordUpdateSyncJob).to receive_message_chain(:set, :perform_later)

        post :password_reset, params: params

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        parsed_reset_url = URI.parse(parsed_response['reset_url'])
        request_signature = params.dig('proof', 'signature')

        expect(parsed_reset_url.host).to eq 'service.oreid.io'
        expect(parsed_reset_url.path).to eq '/auth'
        expect(Rack::Utils.parse_nested_query(parsed_reset_url.query)).to eq(
          'app_access_token' => 'dummy_token',
          'background_color' => 'FFFFFF',
          'callback_url' => 'https://localhost',
          'provider' => 'email',
          'state' => request_signature,
          'hmac' => build(:ore_id_hmac, parsed_response['reset_url'], url_encode: false)
        )
      end
    end
  end
end
