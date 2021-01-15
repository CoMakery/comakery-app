require 'rails_helper'

RSpec.describe PrimariesController, type: :controller do
  describe 'POST #create' do
    let(:account) { create(:account) }
    let(:wallet) { create(:wallet, account: account) }

    before do
      allow(MakePrimaryWallet).to receive(:call).and_return(interactor)
      login(account)
    end

    subject { post :create, params: { wallet_id: wallet.id } }

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
end
