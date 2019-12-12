require 'rails_helper'

RSpec.describe Dashboard::AccountsController, type: :controller do
  let(:project) { create(:project, visibility: :public_listed, token: create(:token, coin_type: :comakery)) }
  let(:account) { create(:account_token_record, token: project.token, max_balance: 2) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { project_id: project.to_param }
      expect(response).to be_successful
    end
  end

  describe 'PUT #update' do
    before do
      login(project.account)
    end

    context 'with valid params' do
      it 'updates account record' do
        put :update, params: { account_token_record: { max_balance: 1 }, id: account.to_param, project_id: project.to_param }
        expect(response).to redirect_to(project_dashboard_accounts_path(project))
        expect(account.reload.max_balance).to eq(1)
      end
    end

    context 'with invalid params' do
      it 'redirects to index with error' do
        put :update, params: { account_token_record: { token_id: create(:token).to_param }, id: account.to_param, project_id: project.to_param }
        expect(response).to redirect_to(project_dashboard_accounts_path(project))
        expect(account.reload.token).to eq(project.token)
      end
    end
  end
end
