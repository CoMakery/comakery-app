require 'rails_helper'

RSpec.describe Dashboard::RegGroupsController, type: :controller do
  let!(:token) { create(:token, coin_type: :comakery) }
  let!(:project) { create(:project, visibility: :public_listed, token: token) }
  let!(:reg_group) { create(:reg_group, token: token) }

  let(:valid_attributes) do
    {
      name: 'Reg S',
      blockchain_id: 1
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      blockchain_id: 2
    }
  end

  before do
    login(project.account)
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new group' do
        expect do
          post :create, params: { reg_group: valid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        end.to change(project.token.reg_groups, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'redirects to transfer rules with error' do
        expect do
          post :create, params: { reg_group: invalid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        end.not_to change(project.token.reg_groups, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      it 'destroys a group' do
        expect do
          delete :destroy, params: { id: reg_group.id, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_rules_path(project))
        end.to change(project.token.reg_groups, :count).by(-1)
      end
    end
  end
end
