require 'rails_helper'

RSpec.describe Dashboard::TransferRulesController, type: :controller do
  let!(:token) { create(:token, coin_type: :comakery) }
  let!(:project) { create(:project, visibility: :public_listed, token: token) }
  let!(:transfer_rule) { create(:transfer_rule, token: token) }

  let(:valid_attributes) do
    {
      sending_group_id: create(:reg_group, token: token).id,
      receiving_group_id: create(:reg_group, token: token).id,
      lockup_until: 1.day.from_now
    }
  end

  let(:invalid_attributes) do
    {
      sending_group_id: create(:reg_group).id,
      receiving_group_id: create(:reg_group, token: token).id,
      lockup_until: 1.day.from_now
    }
  end

  before do
    login(project.account)
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new rule' do
        expect do
          post :create, params: { transfer_rule: valid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        end.to change(project.token.transfer_rules, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'redirects to transfer rules with error' do
        expect do
          post :create, params: { transfer_rule: invalid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        end.not_to change(project.token.transfer_rules, :count)
      end
    end
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
end
