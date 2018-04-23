require 'rails_helper'

describe PaymentsController do
  let!(:team) { create :team }
  let!(:authentication) { create :authentication }
  let!(:account) { authentication.account }
  let!(:my_project) { create(:project, payment_type: 'revenue_share', title: 'Cats', description: 'Cats with lazers', account: account) }
  let!(:other_project) { create(:project, payment_type: 'revenue_share', title: 'Dogs', description: 'Dogs with harpoons', account: create(:account)) }

  before do
    team.build_authentication_team authentication
  end

  describe '#index' do
    it 'owner can see' do
      login account

      get :index, params: { project_id: my_project.id }
      expect(assigns[:project]).to eq(my_project)
    end

    it 'anonymous can access public' do
      other_project.update_attributes(visibility: 'public_listed')

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
    let!(:award_type) { create(:award_type, amount: 1, project: my_project) }
    let!(:revenue) { create :revenue, amount: 100, project: my_project }

    before do
      award_type.awards.create_with_quantity(50, issuer: account, account: account)
    end

    describe 'owner success' do
      before do
        login account
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: 50 } }
      end
      specify { expect(assigns[:project]).to eq(my_project) }
    end

    describe 'owner invalid' do
      before do
        login account
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: '' } }
      end

      specify { expect(response).to render_template('payments/index') }
    end

    describe 'not my project' do
      before do
        login account
        get :create, params: { project_id: other_project.id, payment: { quantity_redeemed: 50 } }
      end
      specify { expect(response).to redirect_to(root_path) }
    end

    describe 'logged out' do
      before do
        get :create, params: { project_id: my_project.id, payment: { quantity_redeemed: 50 } }
      end

      specify { expect(response).to redirect_to(root_url) }
    end
  end

  describe 'update' do
    let!(:award_type) { create(:award_type, amount: 1, project: my_project) }
    let!(:award) { award_type.awards.create_with_quantity(1, issuer: account, account: account) }
    let!(:revenue) { my_project.revenues.create(amount: 100, currency: 'USD', recorded_by: account) }
    let!(:payment) { my_project.payments.create_with_quantity(quantity_redeemed: 1, account: account) }

    before do
      login account
      controller
      patch :update, params: { project_id: my_project.id, id: payment.id, payment: { transaction_fee: 0.50, transaction_reference: 'abc' } }
      payment.reload
    end

    specify { expect(response).to redirect_to(project_payments_path(my_project)) }

    specify { expect(payment.transaction_fee).to eq(0.50) }

    specify { expect(payment.transaction_reference).to eq('abc') }

    specify { expect(payment.reconciled).to eq(true) }

    specify { expect(payment.total_payment).to eq(5.4) }
  end

  describe 'update with blank transaction fee' do
    let!(:award_type) { create(:award_type, amount: 1, project: my_project) }
    let!(:award) { award_type.awards.create_with_quantity(1, issuer: account, account: account) }
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
