require 'rails_helper'

RSpec.describe ProjectRolesController, type: :controller do
  let!(:account) { create(:account) }
  let!(:project) { create(:project, visibility: :public_listed) }
  let(:valid_session) { {} }

  before { login(account) }

  describe 'POST #create' do
    context 'with valid params' do
      it 'project roles the requested project with custom specialty' do
        post :create, params: { project_id: project.id, format: :json }, session: valid_session

        project.reload

        expect(response).to have_http_status(:created)

        expect(project.project_interested).to include(account)
      end
    end

    context 'with invalid params' do
      before { project.project_roles.create(account: account) }

      it 'returns an error' do
        post :create, params: { project_id: project.id, format: :json }, session: valid_session

        project.reload

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)['errors']).to eq(['Account already has a role in project'])
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      let!(:project_role) { create(:project_role, project: project, account: account, role: :observer) }

      it 'removes accounts interests for requested project' do
        delete :destroy, params: { project_id: project.id, id: project_role.id, format: :json }, session: valid_session

        project.reload

        expect(response).to have_http_status(:ok)

        expect(project.project_roles).not_to include(project_role)
      end
    end
  end
end
