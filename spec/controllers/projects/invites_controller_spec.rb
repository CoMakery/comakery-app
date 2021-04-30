require 'rails_helper'

RSpec.describe Projects::InvitesController, type: :controller do
  let!(:admin) { create(:account, comakery_admin: true) }
  let!(:project) { create(:project, account: admin) }
  let!(:account) { create(:account, email: 'example@gmail.com') }

  let!(:params) do
    {
      project_id: project.id,
      email: 'example@gmail.com',
      role: :interested
    }
  end

  before do
    login(project.account)
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new project_role' do
        expect do
          post :create, params: params, format: :json
        end.to change(ProjectRole, :count).by(1)
      end

      it 'returns a success response' do
        post :create, params: params, format: :json
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      let!(:params) do
        {
          project_id: project.id,
          email: 'unregister@gmail.com',
          role: :interested
        }
      end

      it 'respond with errors' do
        post :create, params: params, format: :json
        expect(JSON.parse(response.body)['errors']).to eq(['The user must have signed up to add them'])
      end

      it 'returns a fail response' do
        post :create, params: params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
