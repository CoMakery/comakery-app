require 'rails_helper'

RSpec.describe Dashboard::TransferTypesController, type: :controller do
  let!(:project) { create(:project, visibility: :public_listed) }
  let!(:transfer_type) { create(:transfer_type, project: project) }

  let(:valid_attributes) do
    {
      name: 'Test'
    }
  end

  let(:invalid_attributes) do
    {
      name: 'Earned'
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
      it 'creates a new type' do
        expect do
          post :create, params: { transfer_type: valid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_types_path(project))
        end.to change(project.transfer_types, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'redirects to transfer types with error' do
        expect do
          post :create, params: { transfer_type: invalid_attributes, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_types_path(project))
        end.not_to change(project.transfer_types, :count)
      end
    end
  end

  describe 'PUT #update' do
    before do
      login(project.account)
    end

    context 'with valid params' do
      it 'updates group record' do
        put :update, params: { transfer_type: valid_attributes, id: transfer_type.id, project_id: project.to_param }
        expect(response).to redirect_to(project_dashboard_transfer_types_path(project))
        expect(transfer_type.reload.name).to eq('Test')
      end
    end

    context 'with invalid params' do
      it 'doesnt update group record' do
        put :update, params: { transfer_type: invalid_attributes, id: transfer_type.id, project_id: project.to_param }
        expect(response).to redirect_to(project_dashboard_transfer_types_path(project))
        expect(transfer_type.reload.name).not_to eq('Earned')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      it 'destroys a group' do
        expect do
          delete :destroy, params: { id: transfer_type.id, project_id: project.to_param }
          expect(response).to redirect_to(project_dashboard_transfer_types_path(project))
        end.to change(project.transfer_types, :count).by(-1)
      end
    end
  end
end
