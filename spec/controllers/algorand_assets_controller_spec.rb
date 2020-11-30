require 'rails_helper'
require 'controllers/concerns/ore_id_callbacks_spec'

RSpec.describe AlgorandAssetsController, type: :controller do
  let(:account) { create(:account) }
  let(:asset_token) { create(:asa_token) }
  let(:wallet) do
    account.wallets.create!(
      address: build(:algorand_address_1),
      _blockchain: 'algorand_test',
      source: 'ore_id'
    )
  end

  before do
    login(account)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      asset_token
      wallet
      get :index
      expect(response).to be_successful
    end

    it 'redirects to wallet page if no tokens' do
      wallet
      get :index
      expect(response).to redirect_to '/wallets'
    end

    it 'redirects to wallet page if no algorand wallets' do
      asset_token
      get :index
      expect(response).to redirect_to '/wallets'
    end
  end

  describe 'POST /create' do
    it 'redirects to algorand sign page' do
      allow_any_instance_of(OreIdService).to receive(:create_token).and_return('dummy_token')

      post :create, params: { wallet_id: wallet.id, token_id: asset_token.id }
      expect(response).to redirect_to %r{^https://service.oreid.io/sign?}
    end
  end
end
