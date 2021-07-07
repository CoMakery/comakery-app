require 'rails_helper'

RSpec.describe Projects::Accounts::SettingsController, type: :controller do
  let!(:admin) { create(:account) }
  let!(:project) { create(:project) }
  let!(:account) { create(:account) }
  let!(:project_role) { create(:project_role, project: project, account: account) }

  let!(:params) do
    {
      project_id: project.id,
      account_id: account.id
    }
  end

  before do
    project.project_admins << admin

    login(admin)
  end

  describe 'GET #show' do
    it 'renders a successful response' do
      get :show, params: params

      expect(assigns[:project_role]).to eq(project_role)

      expect(assigns[:project_policy]).not_to be(nil)

      expect(response).to have_http_status(:success)
    end
  end
end
