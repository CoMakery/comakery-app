require 'rails_helper'
require 'controllers/concerns/ore_id_callbacks_spec'

RSpec.describe Auth::OreIdController, type: :controller do
  it_behaves_like 'having ore_id_callbacks'

  before do
    login(create(:account))
  end

  describe 'POST /new' do
    before do
      expect_any_instance_of(described_class).to receive(:auth_url).and_return('/dummy_auth_url')
    end

    it 'redirects to an auth_url' do
      post :new
      expect(response).to redirect_to('/dummy_auth_url')
    end
  end

  describe 'DELETE /destroy' do
    let(:current_ore_id_account) { create(:ore_id, skip_jobs: true) }

    before do
      expect_any_instance_of(described_class).to receive(:current_ore_id_account).and_return(current_ore_id_account)
    end

    it 'destroys current_ore_id_account and redirects to wallets url' do
      expect(current_ore_id_account).to receive(:unlink)
      delete :destroy
      expect(response).to redirect_to(wallets_url)
    end
  end

  describe 'GET /receive' do
    let(:current_ore_id_account) { create(:ore_id, skip_jobs: true) }

    context 'with correct callback' do
      before do
        expect_any_instance_of(described_class).to receive(:verify_errorless).and_return(true)
        expect_any_instance_of(described_class).to receive(:verify_received_account).and_return(true)
        allow_any_instance_of(described_class).to receive(:received_state).and_return({ 'redirect_back_to' => '/dummy_redir_url' })
        allow_any_instance_of(described_class).to receive(:current_ore_id_account).and_return(current_ore_id_account)
      end

      it 'updates ore_id account and redirects to redirect_back_to' do
        expect(current_ore_id_account).to receive(:update).and_return(true)

        get :receive, params: { account: 'dummy_account_name' }
        expect(response).to redirect_to('/dummy_redir_url')
      end
    end

    context 'when callback includes error' do
      before do
        expect_any_instance_of(described_class).to receive(:verify_errorless).exactly(1).times.and_return(false)
        allow_any_instance_of(described_class).to receive(:fallback_state).and_return({ 'redirect_back_to' => '/dummy_redir_url' })
      end

      it 'redirects to redirect_back_to from fallback state with the error' do
        get :receive, params: { account: 'dummy_account_name' }
        expect(response).to redirect_to('/dummy_redir_url')
      end
    end

    context 'when callbacks account doesnt match current one' do
      before do
        expect_any_instance_of(described_class).to receive(:verify_errorless).exactly(1).times.and_return(true)
        expect_any_instance_of(described_class).to receive(:verify_received_account).and_return(false)
      end

      it 'returns 401' do
        get :receive, params: { account: 'dummy_account_name' }
        expect(response).to have_http_status(401)
      end
    end
  end
end
