require 'rails_helper'

RSpec.describe Dashboard::TransfersController, type: :controller do
  let(:project) { create(:project, visibility: :public_listed) }
  let(:transfer) { create(:award, status: :paid, award_type: create(:award_type, project: project)) }
  let(:receiver) { create(:account) }

  let(:valid_attributes) do
    {
      amount: 2,
      quantity: 2,
      why: '-',
      description: '-',
      requirements: '-',
      transfer_type_id: create(:transfer_type, project: project).id.to_s,
      account_id: receiver.to_param
    }
  end

  let(:invalid_attributes) do
    {
      amount: 2,
      quantity: 2,
      why: '-',
      description: '-',
      requirements: '-',
      transfer_type_id: create(:transfer_type, project: project).id.to_s,
      account_id: ''
    }
  end

  before do
    login(project.account)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { project_id: project.to_param }
      expect(response).to be_successful
    end

    context 'when page is out of range' do
      it 'returns a success response with a notice' do
        get :index, params: { project_id: project.to_param, page: 9999 }
        expect(response).to be_successful
        expect(controller).to set_flash[:notice]
      end
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { project_id: project.to_param, id: transfer.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new transfer' do
        expect do
          post :create, params: { award: valid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfers_path(project))
        end.to change(project.awards, :count).by(1)

        award = project.reload.awards.last
        expect(award.name).to eq(award.transfer_type.name.titlecase)
        expect(award.issuer).to eq(project.account)
        expect(award.status).to eq('accepted')
      end
    end

    context 'with invalid params' do
      it 'redirects to transfers with error' do
        expect do
          post :create, params: { award: invalid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfers_path(project))
        end.not_to change(project.awards, :count)
      end
    end
  end
end
