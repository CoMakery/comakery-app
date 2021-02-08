require 'rails_helper'
require 'controllers/concerns/ore_id_callbacks_spec'

RSpec.describe Sign::OreIdController, type: :controller, vcr: true do
  it_behaves_like 'having ore_id_callbacks'

  let(:transaction) { create(:blockchain_transaction) }
  let(:tranfser) { create(:blockchain_transaction).blockchain_transactable }
  let(:project_id) { tranfser.award_type.project_id }

  before do
    login(tranfser.project.account)
  end

  describe 'GET /new' do
    before do
      allow_any_instance_of(AwardPolicy).to receive(:pay?).and_return(true)
      allow_any_instance_of(described_class).to receive(:sign_url).and_return('/dummy_sign_url')
      allow_any_instance_of(Account).to receive(:address_for_blockchain).and_return('dummy_source_address')
    end

    it 'creates a BlockchainTransaction and redirects to a sign_url' do
      get :new, params: { transfer_id: tranfser.id }
      expect(tranfser.blockchain_transactions.last.source).to eq('dummy_source_address')
      expect(request.session[:project_id]).to eq(project_id)
      expect(response).to redirect_to('/dummy_sign_url')
    end
  end

  describe 'GET /receive' do
    let(:current_ore_id_account) { create(:ore_id) }

    context 'with correct callback' do
      before do
        expect_any_instance_of(described_class).to receive(:verify_errorless).exactly(2).times.and_return(true)
        expect_any_instance_of(described_class).to receive(:verify_received_account).and_return(true)
        allow_any_instance_of(AwardPolicy).to receive(:pay?).and_return(true)
        allow_any_instance_of(BlockchainJob::BlockchainTransactionSyncJob).to receive(:perform_later)
        allow_any_instance_of(described_class).to receive(:received_state).and_return({ 'transaction_id' => transaction.id, 'redirect_back_to' => '/dummy_redir_url' })
        allow_any_instance_of(BlockchainTransaction).to receive(:update).and_return(true)
        allow_any_instance_of(BlockchainTransaction).to receive(:update_status)
      end

      it 'updates received transaction, schedules a sync and redirects to redirect_back_to' do
        get :receive, params: { transaction_id: 'dummy_tx_hash', signed_transaction: Base64.encode64('dummy_raw_tx') }
        expect(response).to redirect_to('/dummy_redir_url')
      end
    end

    context 'when callback includes error' do
      before do
        expect_any_instance_of(described_class).to receive(:verify_errorless).exactly(2).times.and_return(false)
      end

      it 'redirects to wallets page with the error' do
        get :receive, params: { transaction_id: 'dummy_tx_hash', signed_transaction: Base64.encode64('dummy_raw_tx') }
        expect(response).to redirect_to(wallets_url)
      end

      context 'when session has project_id' do
        before do
          request.session[:project_id] = project_id
        end

        it 'redirects to project transfers page with the error' do
          get :receive, params: { transaction_id: 'dummy_tx_hash', signed_transaction: Base64.encode64('dummy_raw_tx') }
          expect(response).to redirect_to(project_dashboard_transfers_url(project_id))
        end
      end
    end

    context 'when callbacks account doesnt match current one' do
      before do
        expect_any_instance_of(described_class).to receive(:verify_errorless).exactly(2).times.and_return(true)
        expect_any_instance_of(described_class).to receive(:verify_received_account).and_return(false)
      end

      it 'returns 401' do
        get :receive, params: { transaction_id: 'dummy_tx_hash', signed_transaction: Base64.encode64('dummy_raw_tx') }
        expect(response).to have_http_status(401)
      end
    end
  end
end
