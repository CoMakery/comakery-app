require 'rails_helper'

# TODO: Deprecated
describe RevenuesController, skip: true do
  let!(:team) { create :team }
  let!(:authentication) { create :authentication }
  let!(:account) { authentication.account }
  let!(:my_project) { create(:project, title: 'Cats', description: 'Cats with lazers', account: account) }
  let!(:other_project) { create(:project, title: 'Dogs', description: 'Dogs with harpoons', account: create(:account)) }

  before do
    team.build_authentication_team authentication
    my_project.revenue_share!
    other_project.revenue_share!
    allow(controller).to receive(:policy_scope).and_call_original
    allow(controller).to receive(:authorize).and_call_original
  end

  describe '#index' do
    it 'owner can see' do
      login account
      expect(my_project.revenue_share?).to be true
      get :index, params: { project_id: my_project.id }
      expect(controller).to have_received(:policy_scope).with(Project)
      expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_revenue_info?)
      expect(response).to render_template('revenues/index')
    end

    it 'anonymous can access public' do
      other_project.update_attributes(visibility: 'public_listed')

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
      expect(assigns[:project]).to be_nil
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

      specify { expect(response.status).to eq 200 }
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

      specify { expect(response).to redirect_to(new_account_url) }
    end
  end
end
