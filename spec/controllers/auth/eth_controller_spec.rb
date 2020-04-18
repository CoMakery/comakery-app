require 'rails_helper'

RSpec.describe Auth::EthController, type: :controller do
  let(:valid_public_address) { '0xF4258B3415Cab41Fc9cE5f9b159Ab21ede0501B1' }
  let(:invalid_public_address) { '0xF4258B3415Cab41Fc9cE5f9b159Ab21ede0501B' }
  let(:valid_signature) { '0x62949f93af21d260a9794ef97a4d6c099b8fe65d391604cc86555ded69c21a5b39bcb6ca672d11b55254c594c8921d6293b0a639510e6ee61177ddfa1490a9291b' }
  let(:invalid_signature) { '0x' }
  let(:valid_session) { {} }

  describe 'GET #new' do
    after do
      Rails.cache.clear
    end

    context 'with valid address' do
      it 'creates and store nonce in cache' do
        params = build(:api_signed_request, { auth_eth: { public_address: valid_public_address } }, auth_eth_index_path, 'GET')
        params[:format] = :json
        get :new, params: params, session: valid_session

        expect(response).to have_http_status(200)
        expect(Rails.cache.read("auth_eth::nonce::#{valid_public_address}")).not_to be_nil
      end
    end

    context 'with invalid address' do
      it 'returns 400' do
        get :new, session: valid_session

        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid signature' do
      before do
        Rails.cache.write("auth_eth::nonce::#{valid_public_address}", 'test', expires_in: 1.hour)
      end

      context 'with existing account' do
        let!(:account) { create(:account, ethereum_wallet: valid_public_address) }

        it 'authenticates' do
          expect do
            params = build(:api_signed_request, { auth_eth: { public_address: valid_public_address, signature: valid_signature } }, auth_eth_index_path, 'POST')
            post :create, params: params, session: valid_session

            expect(response).to redirect_to my_tasks_path
          end.not_to change(Account.all, :count)
        end
      end

      context 'with new account' do
        it 'creates account and authenticates' do
          expect do
            params = build(:api_signed_request, { auth_eth: { public_address: valid_public_address, signature: valid_signature } }, auth_eth_index_path, 'POST')
            post :create, params: params, session: valid_session

            expect(response).to redirect_to my_tasks_path
          end.to change(Account.all, :count).by(1)
        end
      end
    end

    context 'with invalid signature' do
      it 'returns 401' do
        params = build(:api_signed_request, { auth_eth: { public_address: valid_public_address, signature: invalid_signature } }, auth_eth_index_path, 'POST')
        post :create, params: params, session: valid_session

        expect(response).to have_http_status(401)
      end
    end
  end

  context 'with invalid address' do
    it 'returns 400' do
      post :create, session: valid_session

      expect(response).to have_http_status(400)
    end
  end
end
