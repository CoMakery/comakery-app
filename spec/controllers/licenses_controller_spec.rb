require 'rails_helper'

describe LicensesController do
  let!(:account) { create :account }
  let!(:project) do
    create(:project,
      title: 'Cats with Lazers Project',
      description: 'cats with lazers',
      owner_account: account,
      slack_team_id: 'citizencode',
      public: true)
  end

  describe '#index' do
    specify do
      get :index, params: { project_id: project.id }
      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
    end
  end
end
