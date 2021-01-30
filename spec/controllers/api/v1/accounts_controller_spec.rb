require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::AccountsController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_signature'
  it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  let(:valid_attributes) do
    {
      email: "me+#{SecureRandom.hex(20)}@example.com",
      first_name: 'Eva',
      last_name: 'Smith',
      nickname: "hunter-#{SecureRandom.hex(20)}",
      date_of_birth: '1990/01/01',
      country: 'United States of America'
    }
  end

  let(:invalid_attributes) do
    {
      email: '0x'
    }
  end

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'signature check' do
    render_views

    it 'existing nonce' do
      params = build(:api_signed_request, '', api_v1_account_path(id: account.managed_account_id), 'GET')
      params[:id] = account.managed_account_id
      params[:format] = :json

      nonce = params['body']['nonce']
      key = "api::v1::nonce_history:#{active_whitelabel_mission.id}:#{nonce}"
      Rails.cache.write(key, true, expires_in: 1.day)

      get :show, params: params
      expect(response.status).to eq 401
      expect(response.body).to eq '{"errors":{"authentication":"Invalid nonce"}}'
    end
  end

  describe 'GET #show' do
    it 'returns account info by managed_account_id' do
      params = build(:api_signed_request, '', api_v1_account_path(id: account.managed_account_id), 'GET')
      params[:id] = account.managed_account_id
      params[:format] = :json

      get :show, params: params
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new managed account' do
        expect do
          params = build(:api_signed_request, { account: valid_attributes }, api_v1_accounts_path, 'POST')

          post :create, params: params
        end.to change(active_whitelabel_mission.managed_accounts, :count).by(1)
      end

      it 'returns created account' do
        params = build(:api_signed_request, { account: valid_attributes }, api_v1_accounts_path, 'POST')

        post :create, params: params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { account: invalid_attributes }, api_v1_accounts_path, 'POST')

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested account' do
        params = build(:api_signed_request, { account: valid_attributes }, api_v1_account_path(id: account.managed_account_id), 'PUT')
        params[:id] = account.managed_account_id

        put :update, params: params
        account.reload
        expect(account.first_name).to eq(valid_attributes[:first_name])
      end

      it 'returns updated account' do
        params = build(:api_signed_request, { account: valid_attributes }, api_v1_account_path(id: account.managed_account_id), 'PUT')
        params[:id] = account.managed_account_id

        put :update, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { account: invalid_attributes }, api_v1_account_path(id: account.managed_account_id), 'PUT')
        params[:id] = account.managed_account_id

        put :update, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'GET #token_balances' do
    it 'returns token_balances by managed_account_id' do
      params = build(:api_signed_request, '', api_v1_account_token_balances_path(account_id: account.managed_account_id), 'GET')
      params[:account_id] = account.managed_account_id
      params[:format] = :json

      get :token_balances, params: params
      expect(response).to be_successful
    end
  end
end
