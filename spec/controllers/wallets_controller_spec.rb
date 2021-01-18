require 'rails_helper'

RSpec.describe WalletsController, type: :controller do
  let(:valid_attributes) do
    {
      name: build(:wallet).name,
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

  describe 'GET /algorand_opt_ins' do
    it 'renders json with content' do
      wallet = account.wallets.create! valid_attributes
      get :algorand_opt_ins, params: { id: wallet.to_param }
      expect(JSON.parse(response.body)).to have_key('content')
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get :new
      expect(response).to redirect_to wallets_path
    end

    context 'json type' do
      it 'renders a successful response' do
        get :new, format: :json
        expect(JSON.parse(response.body)).to have_key('content')
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /edit' do
    let(:wallet) { account.wallets.create! valid_attributes }

    it 'render a successful response' do
      get :edit, params: { id: wallet.to_param }
      expect(response).to redirect_to wallets_path
    end

    context 'json type' do
      it 'renders a successful response' do
        get :edit, format: :json, params: { id: wallet.to_param }
        expect(JSON.parse(response.body)).to have_key('content')
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Wallet' do
        expect do
          post :create, params: { wallet: valid_attributes }
        end.to change(account.wallets, :count).by(1)
      end

      it 'returns json with message and statu 201' do
        post :create, params: { wallet: valid_attributes }
        expect(JSON.parse(response.body)).to have_key('message')
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Wallet' do
        expect do
          post :create, params: { wallet: invalid_attributes }
        end.to change(account.wallets, :count).by(0)
      end

      it 'returns json with message and status 422' do
        post :create, params: { wallet: invalid_attributes }
        expect(JSON.parse(response.body)).to have_key('message')
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_address) { '3BMercihVFcgrXycK7dgei3P3d8AKxWqB6' }
      let(:new_name) { 'Another Wallet Name' }
      let(:new_blockchain) { 'algorand' }
      let(:new_attributes) { { name: new_name, address: new_address, _blockchain: new_blockchain } }
      let(:wallet) { create(:wallet, account: account) }

      subject { patch :update, params: { wallet: new_attributes, id: wallet.id } }

      it 'updates the requested wallet' do
        subject
        wallet.reload
        expect(wallet.name).to eq(new_name)
      end

      it 'does not change address' do
        subject
        wallet.reload
        expect(wallet.address).not_to eq(new_address)
      end

      it 'does not change _blockchain' do
        subject
        wallet.reload
        expect(wallet._blockchain).not_to eq(new_blockchain)
      end

      it 'returns json with message and status 200' do
        subject
        wallet.reload
        expect(JSON.parse(response.body)).to have_key('message')
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid parameters' do
      let(:wallet) { create(:wallet, account: account) }

      subject { patch :update, params: { wallet: { name: '' }, id: wallet.id } }

      it 'returns json with message and status 422' do
        expect { subject }.not_to change(wallet, :name)
        expect(JSON.parse(response.body)).to have_key('message')
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH #make_primary' do
    let(:wallet) { create(:wallet, account: account) }

    before do
      allow(MakePrimaryWallet).to receive(:call).and_return(interactor)
    end

    subject { patch :make_primary, params: { id: wallet.id } }

    context 'request succeed' do
      let(:interactor) { OpenStruct.new(success?: true) }

      it 'redirects to wallets page and sets notice message' do
        subject
        expect(response).to redirect_to wallets_path
        expect(flash[:notice]).to eq('The wallet is successfully set as Primary')
      end
    end

    context 'request fails' do
      let(:interactor) { OpenStruct.new(success?: false, error: 'Wallet Update Failed') }

      it 'redirects to wallets page and sets error message' do
        subject
        expect(response).to redirect_to wallets_path
        expect(flash[:error]).to eq('Wallet Update Failed')
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
