require 'rails_helper'

RSpec.describe Api::V1::VerificationsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, account: account) }

  let(:valid_session) { {} }

  let(:valid_headers) do
    {
      'API-Key' => build(:api_key)
    }
  end

  let(:invalid_headers) do
    {
      'API-Key' => '12345'
    }
  end

  before do
    request.headers.merge! valid_headers
  end

  describe 'GET #index' do
    it 'returns account verifications' do
      params = build(:api_signed_request, '', api_v1_account_verifications_path(account_id: account.managed_account_id), 'GET')
      params[:account_id] = account.managed_account_id
      params[:format] = :json

      get :index, params: params, session: valid_session
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_account_verifications_path(account_id: account.managed_account_id), 'GET')
      params.merge!(account_id: account.managed_account_id, format: :json, page: 9999)

      get :index, params: params, session: valid_session
      expect(response).to be_successful
      expect(assigns[:verifications]).to eq([])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates verification' do
        expect do
          params = build(:api_signed_request, { verification: { passed: 'true', max_investment_usd: '1' } }, api_v1_account_verifications_path(account_id: account.managed_account_id), 'POST')
          params[:account_id] = account.managed_account_id

          post :create, params: params, session: valid_session
        end.to change(account.verifications, :count).by(1)
      end

      it 'redirects to the api_v1_account_verifications' do
        params = build(:api_signed_request, { verification: { passed: 'true', max_investment_usd: '1' } }, api_v1_account_verifications_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params, session: valid_session
        expect(response).to redirect_to(api_v1_account_verifications_path)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { verification: { max_investment_usd: '0' } }, api_v1_account_verifications_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end
end
