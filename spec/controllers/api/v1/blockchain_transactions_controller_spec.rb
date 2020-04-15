require 'rails_helper'

RSpec.describe Api::V1::BlockchainTransactionsController, type: :controller do
  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:blockchain_transaction) { create(:blockchain_transaction) }
  let!(:project) { blockchain_transaction.award.project }

  let!(:valid_create_attributes) do
    {
      transaction: {
        source: build(:ethereum_address_1),
        nonce: 1
      }
    }
  end

  let(:valid_session) { {} }

  let(:valid_headers) do
    {
      'API-Key' => build(:api_key)
    }
  end

  before do
    project.update(mission: active_whitelabel_mission)
    request.headers.merge! valid_headers
  end

  describe 'POST #create', vcr: true do
    context 'with transfers available for transaction' do
      let!(:award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }

      it 'creates a new BlockchainTransaction' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        expect do
          post :create, params: params, session: valid_session
        end.to change(project.blockchain_transactions, :count).by(1)
      end

      it 'returns a success response' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:created)
      end
    end

    context 'without transfers available for transaction' do
      it 'returns an error' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid token' do
      let!(:award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }

      it 'returns an error' do
        project.token.update(coin_type: :btc)

        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with supplied valid transfer id' do
      let!(:award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }

      it 'creates a new BlockchainTransaction for the transfer id' do
        params = build(:api_signed_request, valid_create_attributes.merge(award_id: award.id), api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        expect do
          post :create, params: params, session: valid_session
        end.to change(project.blockchain_transactions, :count).by(1)
      end

      it 'returns a success response' do
        params = build(:api_signed_request, valid_create_attributes.merge(award_id: award.id), api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:created)
      end
    end

    context 'with supplied invalid transfer id' do
      it 'returns an error' do
        params = build(:api_signed_request, valid_create_attributes.merge(award_id: 0), api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params, session: valid_session
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'PUT #update' do
    it 'marks transaction as pending' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      put :update, params: params, session: valid_session
      expect(blockchain_transaction.reload.status).to eq('pending')
    end

    it 'returns a success response' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      put :update, params: params, session: valid_session
      expect(response).to have_http_status(:success)
    end
  end

  describe 'DELETE #destroy' do
    it 'marks transaction as cancelled' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      delete :destroy, params: params, session: valid_session
      expect(blockchain_transaction.reload.status).to eq('cancelled')
    end

    it 'returns a success response' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      delete :destroy, params: params, session: valid_session
      expect(response).to have_http_status(:success)
    end
  end
end
