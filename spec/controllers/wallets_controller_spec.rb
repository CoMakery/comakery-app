require 'rails_helper'

RSpec.describe WalletsController, type: :controller do
  let(:valid_attributes) do
    {
      address: build(:wallet).address,
      _blockchain: build(:wallet)._blockchain
    }
  end

  let(:invalid_attributes) do
    {
      address: '0x'
    }
  end

  let!(:account) { create(:account) }

  before do
    account.wallets.delete_all
    login(account)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      account.wallets.create! valid_attributes
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      wallet = account.wallets.create! valid_attributes
      get :show, params: { id: wallet.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      wallet = account.wallets.create! valid_attributes
      get :edit, params: { id: wallet.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Wallet' do
        expect do
          post :create, params: { wallet: valid_attributes }
        end.to change(account.wallets, :count).by(1)
      end

      it 'redirects to wallets' do
        post :create, params: { wallet: valid_attributes }
        expect(response).to redirect_to(wallets_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Wallet' do
        expect do
          post :create, params: { wallet: invalid_attributes }
        end.to change(account.wallets, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post :create, params: { wallet: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          address: '3CMercihVFcgrXycK7dgei3P3d8AKxWqB6'
        }
      end

      it 'updates the requested wallet' do
        wallet = account.wallets.create! valid_attributes
        patch :update, params: { wallet: new_attributes, id: wallet.to_param }
        wallet.reload
        expect(wallet.address).to eq('3CMercihVFcgrXycK7dgei3P3d8AKxWqB6')
      end

      it 'redirects to wallets' do
        wallet = account.wallets.create! valid_attributes
        patch :update, params: { wallet: new_attributes, id: wallet.to_param }
        wallet.reload
        expect(response).to redirect_to(wallets_url)
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        wallet = account.wallets.create! valid_attributes
        patch :update, params: { wallet: invalid_attributes, id: wallet.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested wallet' do
      wallet = account.wallets.create! valid_attributes
      expect do
        delete :destroy, params: { id: wallet.to_param }
      end.to change(Wallet, :count).by(-1)
    end

    it 'redirects to the wallets list' do
      wallet = account.wallets.create! valid_attributes
      delete :destroy, params: { id: wallet.to_param }
      expect(response).to redirect_to(wallets_url)
    end

    context 'when wallet cannot be destroyed' do
      it 'redirects to the wallets list' do
        wallet = create(:wallet, source: :ore_id, account: account, ore_id_account: create(:ore_id, skip_jobs: true))
        delete :destroy, params: { id: wallet.to_param }
        expect(response).to redirect_to(wallets_url)
      end
    end
  end
end
