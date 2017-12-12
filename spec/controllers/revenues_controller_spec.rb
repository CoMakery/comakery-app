require 'rails_helper'

describe RevenuesController do
  let!(:account) { create(:account, email: 'account@example.com').tap { |a| create(:authentication, account: a, slack_team_id: 'foo', slack_user_name: 'account', slack_user_id: 'account slack_user_id', slack_team_domain: 'foobar') } }
  let!(:my_project) { create(:project, title: 'Cats', description: 'Cats with lazers', owner_account: account, slack_team_id: 'foo') }
  let!(:other_project) { create(:project, title: 'Dogs', description: 'Dogs with harpoons', owner_account: account, slack_team_id: 'bar') }

  before do
    allow(controller).to receive(:policy_scope).and_call_original
    allow(controller).to receive(:authorize).and_call_original
  end

  describe '#index' do
    it 'owner can see' do
      login account

      get :index, params: { project_id: my_project.id }
      expect(controller).to have_received(:policy_scope).with(Project)
      expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_revenue_info?)
    end

    it 'anonymous can access public' do
      other_project.update_attributes(public: true)

      get :index, params: { project_id: other_project.id }
      expect(controller).to have_received(:policy_scope).with(Project)
      expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_revenue_info?)
    end

    it "anonymous can't access private" do
      other_project.update_attributes(public: false)

      get :index, params: { project_id: other_project.id }
      expect(controller).to have_received(:policy_scope).with(Project)
      expect(controller).not_to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_revenue_info?)
      expect(response).to redirect_to('/404.html')
    end
  end

  describe '#create' do
    describe 'owner success' do
      before do
        login account
        get :create, params: { project_id: my_project.id, revenue: { amount: 50 } }
      end

      specify { expect(controller).to have_received(:policy_scope).with(Project) }

      specify { expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to redirect_to(project_revenues_path(my_project)) }
    end

    describe 'owner invalid' do
      before do
        login account
        get :create, params: { project_id: my_project.id, revenue: { amount: '' } }
      end

      specify { expect(controller).to have_received(:policy_scope).with(Project) }

      specify { expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to render_template('revenues/index') }
    end

    describe 'not my project' do
      before do
        login account
        get :create, params: { project_id: other_project.id, revenue: { amount: 50 } }
      end

      specify { expect(controller).to have_received(:policy_scope).with(Project) }

      specify { expect(controller).not_to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to redirect_to('/404.html') }
    end

    describe 'logged out' do
      before do
        get :create, params: { project_id: my_project.id, revenue: { amount: 50 } }
      end

      specify { expect(controller).not_to have_received(:policy_scope).with(Project) }

      specify { expect(controller).not_to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to redirect_to(root_url) }
    end
  end
end
