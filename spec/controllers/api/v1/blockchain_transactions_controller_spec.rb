require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'
require 'controllers/api/v1/concerns/authorizable_by_project_key_spec'
require 'controllers/api/v1/concerns/authorizable_by_project_policy_spec'

RSpec.describe Api::V1::BlockchainTransactionsController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'authorizable_by_mission_key'
  it_behaves_like 'authorizable_by_project_key'
  it_behaves_like 'authorizable_by_project_policy'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:blockchain_transaction) { create(:blockchain_transaction) }
  let!(:project) { blockchain_transaction.blockchain_transactable.project }

  let!(:valid_create_attributes) do
    {
      transaction: {
        source: build(:ethereum_address_1),
        nonce: 1
      }
    }
  end

  before do
    project.update(mission: active_whitelabel_mission)
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'POST #create', vcr: true do
    context 'with awards available for transaction' do
      let!(:award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }
      let!(:wallet) { create(:wallet, account: award.account, _blockchain: project.token._blockchain, address: build(:ethereum_address_1)) }

      it 'creates a new BlockchainTransaction' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        expect do
          post :create, params: params
        end.to change(project.blockchain_transactions, :count).by(1)

        expect(project.blockchain_transactions.last).to be_a(BlockchainTransactionAward)
      end

      it 'returns a success response' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with account_token_records available for transaction' do
      let!(:account_token_record) { create(:account_token_record, account: project.account, token: project.token) }

      it 'creates a new BlockchainTransaction' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        expect do
          post :create, params: params
        end.to change(project.blockchain_transactions, :count).by(1)

        expect(project.blockchain_transactions.last).to be_a(BlockchainTransactionAccountTokenRecord)
      end

      it 'returns a success response' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with frozen token' do
      let!(:account_token_record) { create(:account_token_record, account: project.account, token: project.token) }

      before do
        project.token.update(token_frozen: true)
      end

      it 'returns an error' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'without transactables available for transaction' do
      it 'returns an error' do
        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid token' do
      let!(:award) { create(:award, status: :accepted, award_type: create(:award_type, project: project)) }

      it 'returns an error' do
        project.token.update(_token_type: :btc, _blockchain: :bitcoin)

        params = build(:api_signed_request, valid_create_attributes, api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with custom blockchain_transactable_type' do
      let!(:transfer_rule) { create(:transfer_rule, token: project.token) }

      it 'creates a new BlockchainTransaction for the blockchain_transactable_type' do
        params = build(:api_signed_request, valid_create_attributes.merge(blockchain_transactable_type: 'transfer_rules'), api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        expect do
          post :create, params: params
        end.to change(project.blockchain_transactions, :count).by(1)

        expect(project.blockchain_transactions.last).to be_a(BlockchainTransactionTransferRule)
      end

      it 'returns a success response' do
        params = build(:api_signed_request, valid_create_attributes.merge(blockchain_transactable_type: 'transfer_rules'), api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
        params[:project_id] = project.id

        post :create, params: params
        expect(response).to have_http_status(:created)
      end

      context 'and valid custom blockchain_transactable_id' do
        subject do
          params = build(
            :api_signed_request,
            valid_create_attributes.merge(
              blockchain_transactable_type: 'transfer_rules',
              blockchain_transactable_id: transfer_rule.id
            ),
            api_v1_project_blockchain_transactions_path(
              project_id: project.id
            ),
            'POST'
          )
          params[:project_id] = project.id

          post :create, params: params
        end

        it 'creates a new BlockchainTransaction for the blockchain_transactable_id' do
          expect { subject }.to change(project.blockchain_transactions, :count).by(1)

          expect(project.blockchain_transactions.last).to be_a(BlockchainTransactionTransferRule)
          expect(project.blockchain_transactions.last.blockchain_transactable).to eq(transfer_rule)
        end

        it 'returns a success response' do
          subject
          expect(response).to have_http_status(:created)
        end
      end

      context 'and invalid custom blockchain_transactable_id' do
        it 'returns an error' do
          params = build(:api_signed_request, valid_create_attributes.merge(blockchain_transactable_id: 0), api_v1_project_blockchain_transactions_path(project_id: project.id), 'POST')
          params[:project_id] = project.id

          post :create, params: params
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end

  describe 'PUT #update', vcr: true do
    it 'marks transaction as pending' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      put :update, params: params
      expect(blockchain_transaction.reload.status).to eq('pending')
    end

    it 'returns a success response' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'PUT')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      put :update, params: params
      expect(response).to have_http_status(:success)
    end
  end

  describe 'DELETE #destroy', vcr: true do
    context 'with failed param' do
      it 'marks transaction as failed' do
        params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash, failed: 'true' } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'DELETE')
        params[:project_id] = project.id
        params[:id] = blockchain_transaction.id

        delete :destroy, params: params
        expect(blockchain_transaction.reload.status).to eq('failed')
      end
    end

    it 'marks transaction as cancelled' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'DELETE')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      delete :destroy, params: params
      expect(blockchain_transaction.reload.status).to eq('cancelled')
    end

    it 'returns a success response' do
      params = build(:api_signed_request, { transaction: { tx_hash: blockchain_transaction.tx_hash } }, api_v1_project_blockchain_transaction_path(project_id: project.id, id: blockchain_transaction.id), 'DELETE')
      params[:project_id] = project.id
      params[:id] = blockchain_transaction.id

      delete :destroy, params: params
      expect(response).to have_http_status(:success)
    end
  end
end
