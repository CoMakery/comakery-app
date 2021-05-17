require 'rails_helper'

RSpec.describe Dashboard::AccessesController, type: :controller do
  let!(:project) { create(:project) }
  let!(:project_admin) { create(:account) }

  before do
    login(project.account)
  end

  describe 'GET #index' do
    before do
      project.project_admins << project_admin
    end

    it 'shows admins for current project' do
      get :index, params: { project_id: project.to_param }

      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
      expect(assigns[:admins]).to match_array([project_admin, project.account]) # owner is added as admin
    end
  end

  describe 'POST #regenerate_api_key' do
    it 'regenerates project api key' do
      project.project_admins.delete(project_admin)
      post :regenerate_api_key, params: { project_id: project.to_param }
      project.reload

      expect(response).to redirect_to(project_dashboard_accesses_path(project))
      expect(flash[:notice]).not_to be_nil
      expect(project.api_key.key).not_to be_nil
    end
  end
end
