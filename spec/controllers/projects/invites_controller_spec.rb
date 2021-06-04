require 'rails_helper'

RSpec.describe Projects::InvitesController, type: :controller do
  let!(:admin) { create(:account) }
  let!(:project) { create(:project) }
  let!(:account) { create(:account, email: 'example@gmail.com') }

  let!(:params) do
    {
      project_id: project.id.to_s,
      email: 'example@gmail.com',
      role: 'interested'
    }
  end
  let(:controller_params) do
    ActionController::Parameters.new(params.merge(format: 'json', controller: 'projects/invites', action: 'create'))
  end

  before do
    project.project_admins << admin

    login(admin)
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new project_role' do
        expect(SendInvite).to receive(:call).with(project: project, whitelabel_mission: nil, params: controller_params).and_call_original
        expect do
          post :create, params: params, format: :json
        end.to change(ProjectRole, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      context 'for whitelabel' do
        let(:mission) { create(:active_whitelabel_mission) }
        let!(:admin) { create(:account) }
        let!(:project) { create(:project, mission: mission) }
        let!(:account) { create(:account, email: 'example@gmail.com') }

        before do
          admin.update(managed_mission: mission)
          account.update(managed_mission: mission)
        end

        it 'creates a new project_role' do
          expect(SendInvite).to receive(:call).with(project: project, whitelabel_mission: mission, params: controller_params).and_call_original
          expect do
            post :create, params: params, format: :json
          end.to change(ProjectRole, :count).by(1)
          expect(response).to have_http_status(:created)
          expect(project.project_interested.first).to eq account
        end
      end
    end

    context 'with invalid params' do
      let!(:params) do
        {
          project_id: project.id.to_s,
          email: 'unregister@gmail.com',
          role: 'interested'
        }
      end

      it 'responds with errors' do
        expect(SendInvite).to receive(:call).with(project: project, whitelabel_mission: nil, params: controller_params).and_call_original

        post :create, params: params, format: :json

        expect(JSON.parse(response.body)['errors']).to eq(['The user must have signed up to add them'])
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
