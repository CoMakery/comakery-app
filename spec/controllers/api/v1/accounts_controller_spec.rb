require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  let(:valid_attributes) do
    {
      email: "me+#{SecureRandom.hex(20)}@example.com",
      first_name: 'Eva',
      last_name: 'Smith',
      nickname: "hunter-#{SecureRandom.hex(20)}",
      date_of_birth: '1990/01/01',
      country: 'United States of America',
      ethereum_wallet: '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B'
    }
  end

  let(:invalid_attributes) do
    {
      ethereum_wallet: '0x'
    }
  end

  let(:valid_session) { {} }

  describe 'GET #show' do
    it 'returns account info by managed_account_id' do
      get :show, params: { id: account.managed_account_id, format: :json }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new managed account' do
        expect do
          post :create, params: { account: valid_attributes }, session: valid_session
        end.to change(active_whitelabel_mission.managed_accounts, :count).by(1)
      end

      it 'redirects to the created account' do
        post :create, params: { account: valid_attributes }, session: valid_session
        expect(response).to redirect_to(api_v1_account_path(id: Account.last.managed_account_id))
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        post :create, params: { account: invalid_attributes }, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested account' do
        put :update, params: { id: account.managed_account_id, account: valid_attributes }, session: valid_session
        account.reload
        expect(account.first_name).to eq(valid_attributes[:first_name])
      end

      it 'redirects to the api_v1_account_path' do
        put :update, params: { id: account.managed_account_id, account: valid_attributes }, session: valid_session
        expect(response).to redirect_to(api_v1_account_path)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        put :update, params: { id: account.managed_account_id, account: invalid_attributes }, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'GET #token_balances' do
    it 'returns token_balances by managed_account_id' do
      get :token_balances, params: { account_id: account.managed_account_id, format: :json }, session: valid_session
      expect(response).to be_successful
    end
  end
end
