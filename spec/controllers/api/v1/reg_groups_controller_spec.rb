require 'rails_helper'

RSpec.describe Api::V1::RegGroupsController, type: :controller do
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

  let(:valid_session) { {} }

  let(:valid_headers) do
    {
      'API-Key' => build(:api_key)
    }
  end

  let(:invalid_headers) do
    {
      'API-Key' => '12345'
    }
  end

  before do
    request.headers.merge! valid_headers
  end

  describe 'GET #index' do
    it 'returns records' do
      params = build(:api_signed_request, '', api_v1_project_reg_groups_path(project_id: project.id), 'GET')
      params[:project_id] = project.id
      params[:format] = :json

      get :index, params: params, session: valid_session
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_project_reg_groups_path(project_id: project.id), 'GET')
      params.merge!(project_id: project.id, format: :json, page: 9999)

      get :index, params: params, session: valid_session
      expect(response).to be_successful
      expect(assigns[:reg_groups]).to eq([])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = build(:api_signed_request, '', api_v1_project_reg_group_path(id: reg_group.id, project_id: project.id), 'GET')
      params.merge!(project_id: project.id, id: reg_group.id, format: :json)

      get :show, params: params, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new record' do
        expect do
          params = build(:api_signed_request, { reg_group: valid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST')
          params[:project_id] = project.id

          post :create, params: params, session: valid_session
        end.to change(project.token.reg_groups, :count).by(1)
      end

      it 'returns created record' do
        params = build(:api_signed_request, { reg_group: valid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { reg_group: invalid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
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

        delete :destroy, params: params, session: valid_session
      end.to change(project.token.reg_groups, :count).by(-1)
    end
  end
end
