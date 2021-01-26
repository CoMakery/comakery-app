require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::TransfersController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_signature'
  it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:token, decimal_places: 2)) }
  let!(:transfer) { create(:transfer, award_type: project.default_award_type) }

  let(:valid_attributes) do
    {
      amount: '10.00',
      quantity: '2.00',
      total_amount: '20.00',
      description: 'investor',
      transfer_type_id: create(:transfer_type, project: project).id.to_s,
      account_id: create(:account, managed_mission: active_whitelabel_mission).managed_account_id.to_s
    }
  end

  let(:invalid_attributes) do
    {
      amount: '-1.00',
      account_id: create(:account, managed_mission: active_whitelabel_mission).managed_account_id.to_s
    }
  end

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'GET #index' do
    it 'returns project transfers' do
      params = build(:api_signed_request, '', api_v1_project_transfers_path(project_id: project.id), 'GET')
      params[:project_id] = project.id
      params[:format] = :json

      get :index, params: params
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_project_transfers_path(project_id: project.id), 'GET')
      params.merge!(project_id: project.id, format: :json, page: 9999)

      get :index, params: params
      expect(response).to be_successful
      expect(assigns[:transfers]).to eq([])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer.id, project_id: project.id), 'GET')
      params.merge!(project_id: project.id, id: transfer.id, format: :json)

      get :show, params: params
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new transfer' do
        expect do
          params = build(:api_signed_request, { transfer: valid_attributes }, api_v1_project_transfers_path(project_id: project.id), 'POST')
          params[:project_id] = project.id

          post :create, params: params
        end.to change(project.awards.completed, :count).by(1)
      end

      it 'returns created transfer' do
        params = build(:api_signed_request, { transfer: valid_attributes }, api_v1_project_transfers_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:created)
      end

      it 'fills default values for why, requirements and description' do
        params = build(:api_signed_request, { transfer: valid_attributes.except(:why, :requirements, :description) }, api_v1_project_transfers_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:created)

        award = Award.last
        expect(award.why).to eq ''
        expect(award.requirements).to eq ''
        expect(award.description).to eq ''
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { transfer: invalid_attributes }, api_v1_project_transfers_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end

      context 'when account_id is missing' do
        let(:invalid_attributes) { valid_attributes.merge(account_id: nil) }

        it 'renders an error' do
          params = build(:api_signed_request, { transfer: invalid_attributes }, api_v1_project_transfers_path(project_id: project.id), 'POST')
          params[:project_id] = project.id

          post :create, params: params
          expect(response).not_to be_successful
          expect(assigns[:errors]).not_to be_nil
        end
      end
    end

    context 'with invalid amount precision' do
      it 'renders an error' do
        params = build(:api_signed_request, { transfer: valid_attributes.merge(amount: '1') }, api_v1_project_transfers_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors].messages).to include(amount: ['has incorrect precision (should be 2)'])
      end
    end

    context 'with invalid quantity precision' do
      it 'renders an error' do
        params = build(:api_signed_request, { transfer: valid_attributes.merge(quantity: '1.0124141') }, api_v1_project_transfers_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors].messages).to include(quantity: ['has incorrect precision (should be 2)'])
      end
    end

    context 'with invalid total_amount precision' do
      it 'renders an error' do
        params = build(:api_signed_request, { transfer: valid_attributes.merge(total_amount: '20') }, api_v1_project_transfers_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors].messages).to include(total_amount: ['has incorrect precision (should be 2)'])
      end
    end

    context 'with invalid total_amount value' do
      it 'renders an error' do
        params = build(:api_signed_request, { transfer: valid_attributes.merge(total_amount: '21.00') }, api_v1_project_transfers_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors].messages).to include(total_amount: ["doesn't equal quantity times amount, possible multiplication error"])
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'cancels the requested transfer' do
      expect do
        params = build(:api_signed_request, '', api_v1_project_transfer_path(project_id: project.id, id: transfer.id), 'DELETE')
        params[:project_id] = project.id
        params[:id] = transfer.id

        delete :destroy, params: params
      end.to change(project.awards.where(status: :cancelled), :count).by(1)

      expect(transfer.reload.cancelled?).to be_truthy
    end

    it 'returns cancelled transfer' do
      params = build(:api_signed_request, '', api_v1_project_transfer_path(project_id: project.id, id: transfer.id), 'DELETE')
      params[:project_id] = project.id
      params[:id] = transfer.id

      delete :destroy, params: params
      expect(response).to have_http_status(:ok)
    end
  end
end
