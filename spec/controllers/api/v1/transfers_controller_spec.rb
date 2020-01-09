require 'rails_helper'

RSpec.describe Api::V1::TransfersController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }
  let!(:transfer) { create(:transfer, award_type: project.default_award_type) }

  let(:valid_attributes) do
    {
      amount: 1,
      quantity: 1,
      source: 'bought',
      description: 'investor',
      account_id: create(:account, managed_mission: active_whitelabel_mission).managed_account_id
    }
  end

  let(:invalid_attributes) do
    {
      amount: -1,
      account_id: create(:account, managed_mission: active_whitelabel_mission).managed_account_id
    }
  end

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns project transfers' do
      get :index, params: { project_id: project.id, format: :json }, session: valid_session
      expect(response).to be_successful
    end

    it 'applies pagination' do
      get :index, params: { project_id: project.id, format: :json, page: 9999 }, session: valid_session
      expect(response).to be_successful
      expect(assigns[:transfers]).to eq([])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { project_id: project.id, id: transfer.id, format: :json }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new transfer' do
        expect do
          post :create, params: { project_id: project.id, transfer: valid_attributes }, session: valid_session
        end.to change(project.awards.completed, :count).by(1)
      end

      it 'redirects to the created transfer' do
        post :create, params: { project_id: project.id, transfer: valid_attributes }, session: valid_session
        expect(response).to redirect_to(api_v1_project_transfer_path(project, project.awards.completed.last))
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        post :create, params: { project_id: project.id, transfer: invalid_attributes }, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'cancels the requested transfer' do
      expect do
        delete :destroy, params: { project_id: project.id, id: transfer.id }, session: valid_session
      end.to change(project.awards.where(status: :cancelled), :count).by(1)

      expect(transfer.reload.cancelled?).to be_truthy
    end

    it 'redirects to the cancelled transfer' do
      delete :destroy, params: { project_id: project.id, id: transfer.id }, session: valid_session
      expect(response).to redirect_to(api_v1_project_transfer_path(project, transfer))
    end
  end
end
