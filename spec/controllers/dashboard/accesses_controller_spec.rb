require 'rails_helper'

RSpec.describe Dashboard::AccessesController, type: :controller do
  let!(:project) { create(:project) }
  let!(:project_admin) { create(:account) }

  before do
    login(project.account)
  end

  describe 'GET #index' do
    before do
      project.admins << project_admin
    end

    it 'shows admins for current project' do
      get :index, params: { project_id: project.to_param }

      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
      expect(assigns[:admins]).to match_array([project_admin])
    end
  end

  describe 'POST #add_admin' do
    it 'adds an admin by email to current project' do
      post :add_admin, params: { project_id: project.to_param, email: project_admin.email }
      project.reload

      expect(response).to redirect_to(project_dashboard_accesses_path(project))
      expect(flash[:notice]).not_to be_nil
      expect(project.admins).to match_array([project_admin])
      expect(project.interested).to include(project_admin)
    end

    context 'when account is not found' do
      it 'returns an error' do
        post :add_admin, params: { project_id: project.to_param, email: 'dummy_email' }
        project.reload

        expect(response).to redirect_to(project_dashboard_accesses_path(project))
        expect(flash[:error]).not_to be_nil
        expect(project.admins).to match_array([])
      end
    end

    context 'when account is already an admin' do
      it 'returns an error' do
        project.admins << project_admin
        post :add_admin, params: { project_id: project.to_param, email: project_admin.email }
        project.reload

        expect(response).to redirect_to(project_dashboard_accesses_path(project))
        expect(flash[:error]).not_to be_nil
        expect(project.admins).to match_array([project_admin])
      end
    end

    context 'when account is project owner' do
      it 'returns an error' do
        post :add_admin, params: { project_id: project.to_param, email: project.account.email }
        project.reload

        expect(response).to redirect_to(project_dashboard_accesses_path(project))
        expect(flash[:error]).not_to be_nil
        expect(project.admins).to match_array([])
      end
    end
  end

  describe 'DELETE #remove_admin' do
    before do
      project.admins << project_admin
    end

    it 'removes admin from current project' do
      delete :remove_admin, params: { project_id: project.to_param, account_id: project_admin.id }
      project.reload

      expect(response).to redirect_to(project_dashboard_accesses_path(project))
      expect(flash[:notice]).not_to be_nil
      expect(project.admins).to match_array([])
    end

    context 'when account is not project admin' do
      it 'returns an error' do
        project.admins.delete(project_admin)
        delete :remove_admin, params: { project_id: project.to_param, account_id: project_admin.id }
        project.reload

        expect(response).to redirect_to(project_dashboard_accesses_path(project))
        expect(flash[:error]).not_to be_nil
        expect(project.admins).to match_array([])
      end
    end
  end

  describe 'POST #regenerate_api_key' do
    it 'regenerates project api key' do
      project.admins.delete(project_admin)
      post :regenerate_api_key, params: { project_id: project.to_param }
      project.reload

      expect(response).to redirect_to(project_dashboard_accesses_path(project))
      expect(flash[:notice]).not_to be_nil
      expect(project.api_key.key).not_to be_nil
    end
  end
end
