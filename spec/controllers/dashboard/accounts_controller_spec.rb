require 'rails_helper'

RSpec.describe Dashboard::AccountsController, type: :controller do
  let(:account_token_record) { create(:account_token_record) }
  let(:project) { create(:project, visibility: :public_listed, token: account_token_record.token) }
  let(:account) { account_token_record.account }
  let(:new_account) { create(:account) }

  describe 'GET #index' do
    subject { get :index, params: { project_id: project.to_param } }

    before { project.safe_add_project_interested(account) }

    context 'with eth security token' do
      it { is_expected.to have_http_status(:success) }

      it 'returns interested' do
        subject

        expect(assigns[:accounts]).to include(account)

        expect(assigns[:accounts].ids).to match_array([account.id])
      end
    end

    context 'with algorand security token' do
      let(:account_token_record) { build(:algo_sec_dummy_restrictions) }
      let(:project) { create(:project, visibility: :public_listed, token: account_token_record.token) }

      it { is_expected.to have_http_status(:success) }

      it 'returns interested' do
        subject

        expect(assigns[:accounts]).to include(account)

        expect(assigns[:accounts].ids).to match_array([account.id])
      end
    end

    context 'with a non-security token' do
      let(:project) { create(:project, visibility: :public_listed) }

      it { is_expected.to have_http_status(:success) }

      it 'returns interested' do
        subject

        expect(assigns[:accounts]).to include(project.account)

        expect(assigns[:accounts].ids).to match_array([project.account_id, account.id])
      end
    end

    context 'without token' do
      let(:project) { create(:project, visibility: :public_listed) }

      before { project.update!(token: nil) }

      it { is_expected.to have_http_status(:success) }

      it 'returns interested' do
        subject

        expect(assigns[:accounts]).to include(project.account)

        expect(assigns[:accounts].ids).to match_array([project.account_id, account.id])
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

    before { login(project.account) }

    before { project.safe_add_project_interested(account_token_record.account) }

    context 'with valid params' do
      let(:attributes) { valid_attributes }

      it 'creates a new record' do
        expect { subject }.to change(project.token.account_token_records, :count).by(1)

        account_token_record = project.token.account_token_records.last
        expect(account_token_record.account).to eq new_account
        expect(account_token_record.wallet).to eq new_account.wallets.first
      end

      context 'with a token supported by wallet connect' do
        render_views

        it 'renders json' do
          subject
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to include('tx_new_url')
          expect(JSON.parse(response.body)).to include('tx_receive_url')
        end
      end

      context 'with a token supported by ore id', :vcr do
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
      project.safe_add_project_interested(account)
    end

    it 'returns a success response' do
      get :show, params: { project_id: project.id, id: account.id }, as: :turbo_stream
      expect(response.status).to eq 200
    end
  end

  describe 'POST #refresh_from_blockchain' do
    before { login(project.account) }

    context 'when accounts have been refreshed recently' do
      before do
        create(:account_token_record, token: account_token_record.token, status: :synced, synced_at: Time.current)
      end

      it 'does not run refresh job' do
        expect(AlgorandSecurityToken::AccountTokenRecordsSyncJob).not_to receive(:perform_now)
        post :refresh_from_blockchain, params: { project_id: project.id }

        expect(response).to redirect_to(project_dashboard_accounts_path(project))
      end
    end

    context 'when accounts have not been refreshed recently' do
      context 'with algorand security token', :vcr do
        let(:account_token_record) { create(:blockchain_transaction_account_token_record_algo).blockchain_transactable }

        it 'runs refresh job' do
          expect(AlgorandSecurityToken::AccountTokenRecordsSyncJob).to receive(:perform_now).and_return(true)
          post :refresh_from_blockchain, params: { project_id: project.id }

          expect(response).to redirect_to(project_dashboard_accounts_path(project))
        end
      end

      context 'with comakery security token', :vcr do
        it 'runs refresh job' do
          expect(BlockchainJob::ComakerySecurityTokenJob::AccountTokenRecordsSyncJob).to receive(:perform_now).and_return(true)
          post :refresh_from_blockchain, params: { project_id: project.id }

          expect(response).to redirect_to(project_dashboard_accounts_path(project))
        end
      end
    end
  end
end
