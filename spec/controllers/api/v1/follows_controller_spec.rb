require 'rails_helper'

RSpec.describe Api::V1::FollowsController, type: :controller do
  let!(:account) { create(:account) }
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns account follows' do
      get :index, params: { account_id: account.id, format: :json }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'follows the requested project' do
        post :create, params: { account_id: account.to_param, project_id: project.id }, session: valid_session
        project.reload
        expect(project.interested).to include(account)
      end

      it 'redirects to the api_v1_account_follows' do
        post :create, params: { account_id: account.to_param, project_id: project.id }, session: valid_session
        expect(response).to redirect_to(api_v1_account_follows_path)
      end
    end

    context 'with invalid params' do
      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      it 'renders an error' do
        post :create, params: { account_id: account.to_param, project_id: project.id }, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      it 'unfollows the requested project' do
        delete :destroy, params: { account_id: account.to_param, id: project.id }, session: valid_session
        project.reload
        expect(project.interested).not_to include(account)
      end

      it 'redirects to the api_v1_account_follows' do
        delete :destroy, params: { account_id: account.to_param, id: project.id }, session: valid_session
        expect(response).to redirect_to(api_v1_account_follows_path)
      end
    end
  end
end
