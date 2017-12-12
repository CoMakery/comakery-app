require 'rails_helper'

describe PaymentsController do
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
    let!(:award_type) { create(:award_type, amount: 1, project: my_project) }
    let!(:revenue) { create :revenue, amount: 100, project: my_project }

    before do
      award_type.awards.create_with_quantity(50, issuer: my_project.owner_account, authentication: account.slack_auth)
    end

    describe 'owner success' do
      before do
        login account
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: 50 } }
      end

      specify { expect(controller).to have_received(:policy_scope).with(Project) }

      specify { expect(controller).to have_received(:authorize).with(kind_of(Payment), :create?) }

      specify { expect(controller).to have_received(:authorize).with(kind_of(Project)) }

      specify { expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to redirect_to(project_payments_path(my_project)) }
    end

    describe 'owner invalid' do
      before do
        login account
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: '' } }
      end

      specify { expect(controller).to have_received(:policy_scope).with(Project) }

      specify { expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to render_template('payments/index') }
    end

    describe 'not my project' do
      before do
        login account
        get :create, params: { project_id: other_project.id, payment: { quantity_redeemed: 50 } }
      end

      specify { expect(controller).to have_received(:policy_scope).with(Project) }

      specify { expect(controller).not_to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to redirect_to('/404.html') }
    end

    describe 'logged out' do
      before do
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: 50 } }
      end

      specify { expect(controller).not_to have_received(:policy_scope).with(Project) }

      specify { expect(controller).not_to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to redirect_to(root_url) }
    end
  end

  describe 'update' do
    let!(:award_type) { create(:award_type, amount: 1, project: my_project) }
    let!(:award) { award_type.awards.create_with_quantity(1, issuer: account, authentication: account.slack_auth) }
    let!(:revenue) { my_project.revenues.create(amount: 100, currency: 'USD', recorded_by: account) }
    let!(:payment) { my_project.payments.create_with_quantity(quantity_redeemed: 1, payee_auth: account.slack_auth) }

    before do
      login account
      controller
      patch :update, params: { project_id: my_project.id, id: payment.id, payment: { transaction_fee: 0.50, transaction_reference: 'abc' } }
      payment.reload
    end

    specify { expect(controller).to have_received(:policy_scope).with(Project) }

    specify { expect(controller).to have_received(:authorize).with(kind_of(Payment), :update?) }

    specify { expect(controller).to have_received(:authorize).with(kind_of(Project)) }

    specify { expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project')) }

    specify { expect(response).to redirect_to(project_payments_path(my_project)) }

    specify { expect(payment.transaction_fee).to eq(0.50) }

    specify { expect(payment.transaction_reference).to eq('abc') }

    specify { expect(payment.reconciled).to eq(true) }

    specify { expect(payment.total_payment).to eq(5.4) }
  end

  describe 'update with blank transaction fee' do
    let!(:award_type) { create(:award_type, amount: 1, project: my_project) }
    let!(:award) { award_type.awards.create_with_quantity(1, issuer: account, authentication: account.slack_auth) }
    let!(:revenue) { my_project.revenues.create(amount: 100, currency: 'USD', recorded_by: account) }
    let!(:payment) { my_project.payments.create_with_quantity(quantity_redeemed: 1, payee_auth: account.slack_auth) }

    before do
      login account
      controller
      patch :update, params: { project_id: my_project.id, id: payment.id, payment: { transaction_reference: 'abc' } }
      payment.reload
    end

    specify { expect(response).to redirect_to(project_payments_path(my_project)) }

    specify { expect(payment.transaction_fee).to eq(0) }

    specify { expect(payment.transaction_reference).to eq('abc') }

    specify { expect(payment.reconciled).to eq(true) }

    specify { expect(payment.total_payment).to eq(5.9) }
  end
end
