require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { format: :json }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: project.to_param, format: :json }, session: valid_session
      expect(response).to be_successful
    end
  end
end
