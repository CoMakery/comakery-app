require 'rails_helper'

RSpec.describe Auth::EthController, type: :controller do
  let(:valid_public_address) { '0xF4258B3415Cab41Fc9cE5f9b159Ab21ede0501B1' }
  let(:invalid_public_address) { '0xF4258B3415Cab41Fc9cE5f9b159Ab21ede0501B' }
  let(:valid_nonce) { 'Authentication Request #1587583522817-09f09af12698' }
  let(:valid_timestamp) { 1587583523 }
  let(:valid_signature) { '0x661c02f55ed2804d3948b36fdbed266f710074916059b0591c908ea9a30af0e542dea325acafc71ac84abfdfb44d279318286522c862dc78ff282f9bc74a3ebc1c' }
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
    context 'with valid signature and timestamp' do
      before do
        Rails.cache.write("auth_eth::nonce::#{valid_public_address}", valid_nonce, expires_in: 1.hour)
        travel_to Time.zone.at(valid_timestamp)
      end

      after do
        travel_back
      end

      context 'with existing account' do
        let!(:account) { create(:account, ethereum_auth_address: valid_public_address) }

        it 'authenticates' do
          expect do
            params = build(:api_signed_request, { auth_eth: { public_address: valid_public_address, signature: valid_signature } }, auth_eth_index_path, 'POST')
            post :create, params: params, session: valid_session

            expect(response).to redirect_to my_tasks_path
          end.not_to change(Account.all, :count)
        end
      end

      context 'with new account' do
        it 'creates account, populating wallet address, and authenticates' do
          expect do
            params = build(:api_signed_request, { auth_eth: { public_address: valid_public_address, signature: valid_signature } }, auth_eth_index_path, 'POST')
            post :create, params: params, session: valid_session

            expect(response).to redirect_to my_tasks_path
          end.to change(Account.all, :count).by(1)

          expect(Account.last.wallets.last.address).to eq(valid_public_address)
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
