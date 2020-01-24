require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns a success response' do
      params = build(:api_signed_request, '', api_v1_projects_path, 'GET')
      params[:format] = :json

      get :index, params: params, session: valid_session
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_projects_path, 'GET')
      params[:format] = :json
      params[:page] = 9999

      get :index, params: params, session: valid_session
      expect(response).to be_successful
      expect(assigns[:projects]).to eq([])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = build(:api_signed_request, '', api_v1_project_path(id: project.to_param), 'GET')
      params[:id] = project.to_param
      params[:format] = :json

      get :show, params: params, session: valid_session
      expect(response).to be_successful
    end
  end
end
