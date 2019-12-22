require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  let!(:account) { create(:account) }
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }

  let(:valid_attributes) do
    {
      first_name: 'Alex'
    }
  end

  let(:invalid_attributes) do
    {
      ethereum_wallet: '0x'
    }
  end

  let(:valid_session) { {} }

  describe 'GET #show' do
    it 'returns account info by id' do
      get :show, params: { id: account.id, format: :json }, session: valid_session
      expect(response).to be_successful
    end

    it 'returns account info by email' do
      get :show, params: { id: account.email, format: :json }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested account' do
        put :update, params: { id: account.to_param, account: valid_attributes }, session: valid_session
        account.reload
        expect(account.first_name).to eq(valid_attributes[:first_name])
      end

      it 'redirects to the api_v1_account_path' do
        put :update, params: { id: account.to_param, account: valid_attributes }, session: valid_session
        expect(response).to redirect_to(api_v1_account_path)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        put :update, params: { id: account.to_param, account: invalid_attributes }, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end
end
