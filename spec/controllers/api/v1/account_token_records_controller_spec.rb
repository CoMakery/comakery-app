require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::AccountTokenRecordsController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account_token_record) { create(:account_token_record) }
  let(:account) { account_token_record.account }
  let(:wallet) { account_token_record.wallet }
  let(:new_account) { create(:account) }
  let(:token) { account_token_record.token }

  let(:valid_attributes) do
    {
      max_balance: '100',
      lockup_until: '1',
      reg_group_id: create(:reg_group, token: token).id.to_s,
      account_id: new_account.id.to_s,
      account_frozen: 'false'
    }
  end

  let(:invalid_attributes) do
    {
      max_balance: '-100',
      lockup_until: '1',
      reg_group_id: create(:reg_group, token: token).id.to_s,
      account_id: new_account.id.to_s,
      account_frozen: 'false'
    }
  end

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'GET #index' do
    it 'returns records' do
      params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id), 'GET')
      params[:token_id] = token.id
      params[:format] = :json

      get :index, params: params
      expect(response).to be_successful
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id), 'GET')
      params.merge!(token_id: token.id, format: :json, page: 9999)

      get :index, params: params
      expect(response).to be_successful
      expect(assigns[:account_token_records]).to eq([])
    end

    context 'wallet scope' do
      it 'returns records' do
        params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id, wallet_id: wallet.id), 'GET')
        params.merge!(token_id: token.id, wallet_id: wallet.id, format: :json)

        get :index, params: params
        expect(response).to be_successful
      end

      it 'applies pagination' do
        params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id, wallet_id: wallet.id), 'GET')
        params.merge!(token_id: token.id, wallet_id: wallet.id, format: :json, page: 9999)

        get :index, params: params
        expect(response).to be_successful
        expect(assigns[:account_token_records]).to eq([])
      end
    end

    context 'account scope' do
      it 'returns records' do
        params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id, account_id: account.id), 'GET')
        params.merge!(token_id: token.id, account_id: account.id, format: :json)

        get :index, params: params
        expect(response).to be_successful
      end

      it 'applies pagination' do
        params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id, wallet_id: wallet.id), 'GET')
        params.merge!(token_id: token.id, account_id: account.id, format: :json, page: 9999)

        get :index, params: params
        expect(response).to be_successful
        expect(assigns[:account_token_records]).to eq([])
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new record' do
        expect do
          params = build(:api_signed_request, { account_token_record: valid_attributes }, api_v1_token_account_token_records_path(token_id: token.id), 'POST')
          params[:token_id] = token.id

          post :create, params: params
        end.to change(token.account_token_records, :count).by(1)

        account_token_record = token.account_token_records.last
        expect(account_token_record.account).to eq new_account
        expect(account_token_record.wallet).to eq new_account.wallets.first
      end

      it 'returns created record' do
        params = build(:api_signed_request, { account_token_record: valid_attributes }, api_v1_token_account_token_records_path(token_id: token.id), 'POST')
        params[:token_id] = token.id

        post :create, params: params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, { account_token_record: invalid_attributes }, api_v1_token_account_token_records_path(token_id: token.id), 'POST')
        params[:token_id] = token.id

        post :create, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy_all' do
    context 'account scope' do
      it 'deletes the record' do
        expect do
          params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id, account_id: account.id), 'DELETE')
          params[:token_id] = token.id
          params[:account_id] = account.id

          delete :destroy_all, params: params
        end.to change(token.account_token_records, :count).by(-1)
      end
    end

    context 'wallet scope' do
      it 'deletes the record' do
        expect do
          params = build(:api_signed_request, '', api_v1_token_account_token_records_path(token_id: token.id, wallet_id: wallet.id), 'DELETE')
          params[:token_id] = token.id
          params[:wallet_id] = wallet.id

          delete :destroy_all, params: params
        end.to change(token.account_token_records, :count).by(-1)
      end
    end
  end
end
