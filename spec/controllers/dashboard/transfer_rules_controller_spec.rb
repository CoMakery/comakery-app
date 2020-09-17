require 'rails_helper'

RSpec.describe Dashboard::TransferRulesController, type: :controller do
  let!(:token) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
  let!(:project) { create(:project, visibility: :public_listed, token: token) }
  let!(:transfer_rule) { create(:transfer_rule, token: token) }

  before do
    login(project.account)
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      it 'destroys a rule' do
        expect do
          delete :destroy, params: { id: transfer_rule.id, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        end.to change(project.token.transfer_rules, :count).by(-1)
      end
    end
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { project_id: project.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #pause' do
    context 'with valid params' do
      it 'pauses token' do
        project.token.update(token_frozen: false)

        post :pause, params: { project_id: project.to_param }
        expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        expect(project.token.reload.token_frozen?).to be_truthy
      end
    end
  end

  describe 'POST #unpause' do
    context 'with valid params' do
      it 'unpauses token' do
        project.token.update(token_frozen: true)

        post :unpause, params: { project_id: project.to_param }
        expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        expect(project.token.reload.token_frozen?).to be_falsey
      end
    end
  end
end
