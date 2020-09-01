require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::RegGroupsController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_signature'
  it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:reg_group) { create(:reg_group) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: reg_group.token) }

  let(:valid_attributes) do
    {
      name: 'Test',
      blockchain_id: '10'
    }
  end

  let(:invalid_attributes) do
    {
      blockchain_id: '-15'
    }
  end

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'GET #index' do
    it 'returns records' do
      params = build(:api_signed_request, '', api_v1_project_reg_groups_path(project_id: project.id), 'GET')
      params[:project_id] = project.id
      params[:format] = :json

      get :index, params: params
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_project_reg_groups_path(project_id: project.id), 'GET')
      params.merge!(project_id: project.id, format: :json, page: 9999)

      get :index, params: params
      expect(response).to be_successful
      expect(assigns[:reg_groups]).to eq([])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = build(:api_signed_request, '', api_v1_project_reg_group_path(id: reg_group.id, project_id: project.id), 'GET')
      params.merge!(project_id: project.id, id: reg_group.id, format: :json)

      get :show, params: params
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new record' do
        expect do
          params = build(:api_signed_request, { reg_group: valid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST')
          params[:project_id] = project.id

          post :create, params: params
        end.to change(project.token.reg_groups, :count).by(1)
      end

      it 'returns created record' do
        params = build(:api_signed_request, { reg_group: valid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { reg_group: invalid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the record' do
      expect do
        params = build(:api_signed_request, '', api_v1_project_reg_group_path(id: reg_group.id, project_id: project.id), 'DELETE')
        params[:project_id] = project.id
        params[:id] = reg_group.id

        delete :destroy, params: params
      end.to change(project.token.reg_groups, :count).by(-1)
    end
  end
end
