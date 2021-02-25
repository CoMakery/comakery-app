require 'rails_helper'

RSpec.describe Dashboard::AccountsController, type: :controller do
  let(:account_token_record) { create(:account_token_record) }
  let(:project) { create(:project, visibility: :public_listed, token: account_token_record.token) }
  let(:account) { account_token_record.account }
  let(:new_account) { create(:account) }

  describe 'GET #index' do
    context 'with comakery token' do
      it 'returns a success response' do
        get :index, params: { project_id: project.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        max_balance: '100',
        lockup_until: '1',
        reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
        account_id: new_account.id.to_s,
        account_frozen: 'false'
      }
    end

    let(:invalid_attributes) do
      {
        max_balance: '-100',
        lockup_until: '1',
        reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
        account_id: new_account.id.to_s,
        account_frozen: 'false'
      }
    end

    subject { post :create, params: { project_id: project.id, account_token_record: attributes } }

    before do
      login(project.account)
      project.safe_add_interested(account_token_record.account)
    end

    context 'with valid params' do
      let(:attributes) { valid_attributes }

      it 'creates a new record' do
        expect { subject }.to change(project.token.account_token_records, :count).by(1)

        account_token_record = project.token.account_token_records.last
        expect(account_token_record.account).to eq new_account
        expect(account_token_record.wallet).to eq new_account.wallets.first
      end

      context 'with comakery security token' do
        it 'returns created record' do
          subject
          expect(response).to have_http_status(:created)
        end
      end

      context 'with algorand security token', :vcr do
        let(:account_token_record) { create(:blockchain_transaction_account_token_record_algo).blockchain_transactable }

        it 'redirects to ore_id' do
          subject
          expect(response).to have_http_status(:found)
        end
      end
    end

    context 'with invalid params' do
      let(:attributes) { invalid_attributes }

      it 'renders an error' do
        subject
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end

  describe 'GET #show' do
    before do
      project.interested << account
    end

    it 'returns a success response' do
      get :show, params: { project_id: project.to_param, id: account.id }, as: :turbo_stream
      expect(response.status).to eq 200
    end
  end

  describe 'POST #refresh_from_blockchain' do
    before do
      login(project.account)
    end

    context 'when accounts have been refreshed recently' do
      before do
        create(:account_token_record, token: account_token_record.token, status: :synced, synced_at: Time.current)
      end

      it 'does not run refresh job' do
        expect(AlgorandSecurityToken::AccountTokenRecordsSyncJob).not_to receive(:perform_now)
        post :refresh_from_blockchain, params: { project_id: project.to_param }

        expect(response).to redirect_to(project_dashboard_accounts_path(project))
      end
    end

    context 'when accounts have not been refreshed recently' do
      context 'with algorand security token', :vcr do
        let(:account_token_record) { create(:blockchain_transaction_account_token_record_algo).blockchain_transactable }

        it 'runs refresh job' do
          expect(AlgorandSecurityToken::AccountTokenRecordsSyncJob).to receive(:perform_now).and_return(true)
          post :refresh_from_blockchain, params: { project_id: project.to_param }

          expect(response).to redirect_to(project_dashboard_accounts_path(project))
        end
      end
    end
  end
end
