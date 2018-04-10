require 'rails_helper'

describe RevenuesController do
  let!(:team) { create :team }
  let!(:authentication) { create :authentication }
  let!(:account) { authentication.account }
  let!(:my_project) { create(:project, title: 'Cats', description: 'Cats with lazers', account: account) }
  let!(:other_project) { create(:project, title: 'Dogs', description: 'Dogs with harpoons', account: create(:account)) }

  before do
    team.build_authentication_team authentication
    my_project.revenue_share!
    other_project.revenue_share!
  end

  describe '#index' do
    it 'owner can see' do
      login account
      expect(my_project.revenue_share?).to be true
      get :index, params: { project_id: my_project.id }
      expect(assigns[:project]).to eq(my_project)
    end

    it 'anonymous can access public' do
      other_project.update_attributes(public: true)

      get :index, params: { project_id: other_project.id }
      expect(assigns[:project]).to eq(other_project)
    end

    it "anonymous can't access private" do
      other_project.update_attributes(public: false)

      get :index, params: { project_id: other_project.id }
      expect(assigns[:project]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end

  describe '#create' do
    describe 'owner success' do
      before do
        login account
        get :create, params: { project_id: my_project.id, revenue: { amount: 50 } }
      end

      specify { expect(response).to redirect_to(project_revenues_path(my_project)) }
    end

    describe 'owner invalid' do
      before do
        login account
        get :create, params: { project_id: my_project.id, revenue: { amount: '' } }
      end

      specify { expect(response).to render_template('revenues/index') }
    end

    describe 'not my project' do
      before do
        login account
        get :create, params: { project_id: other_project.id, revenue: { amount: 50 } }
      end

      specify { expect(response).to redirect_to(root_path) }
    end

    describe 'logged out' do
      before do
        get :create, params: { project_id: my_project.id, revenue: { amount: 50 } }
      end

      specify { expect(response).to redirect_to(root_url) }
    end
  end
end
