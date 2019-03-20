require 'rails_helper'

describe PaymentsController do
  let!(:team) { create :team }
  let!(:authentication) { create :authentication }
  let!(:account) { authentication.account }
  let!(:my_project) { create(:project, payment_type: 'revenue_share', title: 'Cats', description: 'Cats with lazers', account: account) }
  let!(:other_project) { create(:project, payment_type: 'revenue_share', title: 'Dogs', description: 'Dogs with harpoons', account: create(:account)) }

  before do
    team.build_authentication_team authentication
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
      other_project.update_attributes(visibility: 'public_listed')

      get :index, params: { project_id: other_project.id }
      expect(controller).to have_received(:policy_scope).with(Project)
      expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_revenue_info?)
    end

    it "anonymous can't access private" do
      other_project.update_attributes(public: false)

      get :index, params: { project_id: other_project.id }
      expect(assigns[:project]).to be_nil
      expect(response).to redirect_to('/404.html')
    end
  end

  describe '#create' do
    let!(:award_type) { create(:award_type, project: my_project) }
    let!(:revenue) { create :revenue, amount: 100, project: my_project }

    before do
      create(:award, award_type: award_type, quantity: 50, amount: 1, issuer: account, account: account)
    end

    describe 'owner success' do
      before do
        login account
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: 50 } }
      end

      specify { expect(assigns[:project]).to eq(my_project) }
      specify { expect(controller).to have_received(:policy_scope).with(Project) }

      specify { expect(controller).to have_received(:authorize).with(kind_of(Payment), :create?) }

      specify { expect(controller).to have_received(:authorize).with(kind_of(Project)) }

      specify { expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project')) }

      specify { expect(response).to redirect_to(project_payments_path(my_project)) }
    end

    describe 'owner invalid' do
      before do
        login account
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: 0 } }
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

      specify { expect(response).to redirect_to(new_account_url) }
    end
  end

  describe 'update' do
    let!(:award_type) { create(:award_type, project: my_project) }
    let!(:award) { create(:award, award_type: award_type, quantity: 1, amount: 1, issuer: account, account: account) }
    let!(:revenue) { my_project.revenues.create(amount: 100, currency: 'USD', recorded_by: account) }
    let!(:payment) { my_project.payments.create_with_quantity(quantity_redeemed: 1, account: account) }

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
    let!(:award_type) { create(:award_type, project: my_project) }
    let!(:award) { create(:award, award_type: award_type, quantity: 1, amount: 1, issuer: account, account: account) }
    let!(:revenue) { my_project.revenues.create(amount: 100, currency: 'USD', recorded_by: account) }
    let!(:payment) { my_project.payments.create_with_quantity(quantity_redeemed: 1, account: account) }

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
