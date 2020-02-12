require 'rails_helper'

RSpec.describe Api::V1::InterestsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  let(:valid_session) { {} }

  let(:valid_headers) do
    {
      'API-Key' => build(:api_key)
    }
  end

  let(:invalid_headers) do
    {
      'API-Key' => '12345'
    }
  end

  before do
    request.headers.merge! valid_headers
  end

  describe 'GET #index' do
    it 'returns account interests' do
      params = build(:api_signed_request, '', api_v1_account_interests_path(account_id: account.managed_account_id), 'GET')
      params[:account_id] = account.managed_account_id
      params[:format] = :json

      get :index, params: params, session: valid_session
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_account_interests_path(account_id: account.managed_account_id), 'GET')
      params.merge!(account_id: account.managed_account_id, format: :json, page: 9999)

      get :index, params: params, session: valid_session
      expect(response).to be_successful
      expect(assigns[:interests]).to eq([])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'interests the requested project' do
        params = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_interests_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params, session: valid_session
        project.reload
        expect(project.interested).to include(account)
      end

      it 'returns list of account interests' do
        params = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_interests_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      it 'renders an error' do
        params = build(:api_signed_request, { project_id: project.id.to_s }, api_v1_account_interests_path(account_id: account.managed_account_id), 'POST')
        params[:account_id] = account.managed_account_id

        post :create, params: params, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      it 'uninterests the requested project' do
        params = build(:api_signed_request, '', api_v1_account_interest_path(account_id: account.managed_account_id, id: project.id), 'DELETE')
        params[:account_id] = account.managed_account_id
        params[:id] = project.id

        delete :destroy, params: params, session: valid_session
        project.reload
        expect(project.interested).not_to include(account)
      end

      it 'returns list of account interests' do
        params = build(:api_signed_request, '', api_v1_account_interest_path(account_id: account.managed_account_id, id: project.id), 'DELETE')
        params[:account_id] = account.managed_account_id
        params[:id] = project.id

        delete :destroy, params: params, session: valid_session
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
