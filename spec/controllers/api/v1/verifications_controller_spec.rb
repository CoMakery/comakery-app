require 'rails_helper'

RSpec.describe Api::V1::VerificationsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:verification) { create(:verification, account: account) }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns account verifications' do
      get :index, params: { account_id: account.managed_account_id, format: :json }, session: valid_session
      expect(response).to be_successful
    end

    it 'applies pagination' do
      get :index, params: { account_id: account.managed_account_id, format: :json, page: 9999 }, session: valid_session
      expect(response).to be_successful
      expect(assigns[:verifications]).to eq([])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates verification' do
        expect do
          post :create, params: { account_id: account.managed_account_id, verification: { passed: true, max_investment_usd: 1 } }, session: valid_session
        end.to change(account.verifications, :count).by(1)
      end

      it 'redirects to the api_v1_account_verifications' do
        post :create, params: { account_id: account.managed_account_id, verification: { passed: true, max_investment_usd: 1 } }, session: valid_session
        expect(response).to redirect_to(api_v1_account_verifications_path)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        post :create, params: { account_id: account.managed_account_id, verification: { max_investment_usd: 0 } }, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end
end
