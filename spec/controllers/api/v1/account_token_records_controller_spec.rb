require 'rails_helper'

RSpec.describe Api::V1::AccountTokenRecordsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account_token_record) { create(:account_token_record) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: account_token_record.token) }

  let(:valid_attributes) do
    {
      max_balance: '100',
      lockup_until: '1',
      reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
      account_id: create(:account).id.to_s,
      account_frozen: 'false'
    }
  end

  let(:invalid_attributes) do
    {
      max_balance: '-100',
      lockup_until: '1',
      reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
      account_id: create(:account).id.to_s,
      account_frozen: 'false'
    }
  end

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

    project.safe_add_interested(account_token_record.account)
  end

  describe 'GET #index' do
    it 'returns records' do
      params = build(:api_signed_request, '', api_v1_project_account_token_records_path(project_id: project.id), 'GET')
      params[:project_id] = project.id
      params[:format] = :json

      get :index, params: params, session: valid_session
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_project_account_token_records_path(project_id: project.id), 'GET')
      params.merge!(project_id: project.id, format: :json, page: 9999)

      get :index, params: params, session: valid_session
      expect(response).to be_successful
      expect(assigns[:account_token_records]).to eq([])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = build(:api_signed_request, '', api_v1_project_account_token_record_path(id: account_token_record.id, project_id: project.id), 'GET')
      params.merge!(project_id: project.id, id: account_token_record.id, format: :json)

      get :show, params: params, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new record' do
        expect do
          params = build(:api_signed_request, { account_token_record: valid_attributes }, api_v1_project_account_token_records_path(project_id: project.id), 'POST')
          params[:project_id] = project.id

          post :create, params: params, session: valid_session
        end.to change(project.token.account_token_records, :count).by(1)
      end

      it 'returns created record' do
        params = build(:api_signed_request, { account_token_record: valid_attributes }, api_v1_project_account_token_records_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:created)
      end

      it 'adds record account to project interested' do
        params = build(:api_signed_request, { account_token_record: valid_attributes }, api_v1_project_account_token_records_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(project.interested).to include(AccountTokenRecord.last.account)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { account_token_record: invalid_attributes }, api_v1_project_account_token_records_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the record' do
      expect do
        params = build(:api_signed_request, '', api_v1_project_account_token_record_path(id: account_token_record.id, project_id: project.id), 'DELETE')
        params[:project_id] = project.id
        params[:id] = account_token_record.id

        delete :destroy, params: params, session: valid_session
      end.to change(project.token.account_token_records, :count).by(-1)
    end
  end
end
