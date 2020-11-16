require 'rails_helper'

RSpec.describe Sign::OreIdController, type: :controller do
  let(:tranfser) { create(:blockchain_transaction__award) }
  let(:transaction) { create(:blockchain_transaction) }

  before do
    login(tranfser.project.account)
  end

  describe 'GET /new' do
    before do
      expect_any_instance_of(AwardPolicy).to receive(:pay?).and_return(true)
      expect_any_instance_of(described_class).to receive(:sign_url).and_return('/dummy_sign_url')
      expect_any_instance_of(Account).to receive(:address_for_blockchain).and_return('dummy_source_address')
    end

    it 'creates a BlockchainTransaction and redirects to a sign_url' do
      get :new, params: { transfer_id: tranfser.id }
      expect(tranfser.blockchain_transactions.last.source).to eq('dummy_source_address')
      expect(response).to redirect_to('/dummy_sign_url')
    end
  end

  describe 'GET /receive' do
    let(:current_ore_id_account) { create(:ore_id) }

    before do
      expect_any_instance_of(described_class).to receive(:verify_errorless)
      expect_any_instance_of(described_class).to receive(:verify_received_account)
      expect_any_instance_of(AwardPolicy).to receive(:pay?).and_return(true)
      expect_any_instance_of(BlockchainJob::BlockchainTransactionSyncJob).to receive(:perform_later)
      expect_any_instance_of(described_class).to receive(:received_state).and_return({ 'redirect_back_to' => '/dummy_redir_url' })
    end

    it 'updates received transaction, schedules a sync and redirects to redirect_back_to' do
      expect(transaction).to receive(:update).and_return(true)
      expect(transaction).to receive(:update_status)

      get :receive, params: { transaction_id: transaction.id }
      expect(response).to redirect_to('/dummy_redir_url')
    end
  end
end
