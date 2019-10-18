require 'rails_helper'

RSpec.describe Dashboard::TransfersController, type: :controller do
  let(:project) { create(:project, visibility: :public_listed) }
  let(:receiver) { create(:account) }

  let(:valid_attributes) do
    {
      amount: 2,
      quantity: 2,
      source: 'bought',
      why: '-',
      description: '-',
      requirements: '-',
      account_id: receiver.to_param
    }
  end

  let(:invalid_attributes) do
    {
      amount: 2,
      quantity: 2,
      source: 'bought',
      why: '-',
      description: '-',
      requirements: '-',
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
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new transfer' do
        expect do
          post :create, params: { award: valid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfers_path(project))
        end.to change(project.awards, :count).by(1)

        award = project.reload.awards.last
        expect(award.name).to eq('Bought')
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
