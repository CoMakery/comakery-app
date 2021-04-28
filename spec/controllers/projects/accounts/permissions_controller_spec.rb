require 'rails_helper'

RSpec.describe Projects::Accounts::PermissionsController, type: :controller do
  let!(:admin) { create(:account, comakery_admin: true) }
  let!(:project) { create(:project, account: admin) }
  let!(:account) { create(:account, email: 'example@gmail.com') }
  let!(:interest) { create(:interest, project: project, account: account, role: :member) }

  let!(:params) do
    {
      id: interest.id,
      project_id: project.id,
      account_id: account.id,
      interest: { role: :admin }
    }
  end

  before do
    login(project.account)
  end

  describe 'GET #show' do
    it 'renders a successful response' do
      get :show, params: params, format: :json
      expect(JSON.parse(response.body)).to have_key('content')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #update' do
    it 'updates permissions' do
      put :update, params: params, format: :json
      expect(interest.reload.role).to eq('admin')
      expect(response).to have_http_status(:ok)
    end
  end
end
