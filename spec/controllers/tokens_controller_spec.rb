require 'rails_helper'

describe TokensController do
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:account) { create :account }

  before do
    login(admin_account)
  end

  describe '#new' do
    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in without admin flag' do
      it 'redirects to root' do
        login(account)
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in with admin flag' do
      it 'returns correct react component' do
        get :new
        expect(response.status).to eq(200)
        expect(assigns[:token]).to be_a_new_record
      end
    end
  end

  describe '#create' do
    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        post :create
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in without admin flag' do
      it 'redirects to root' do
        login(account)
        post :create
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in with admin flag' do
      it 'creates a token if valid data supplied' do
        expect do
          post :create, params: {
            token: {
              name: 'Cat Token',
              logo_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              symbol: 'CAT'
            }
          }
          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json')
        end.to change { Token.count }.by(1)

        token = Token.last
        expect(token.name).to eq('Cat Token')
        expect(token.logo_image).to be_a(Refile::File)
        expect(token.symbol).to eq('CAT')
      end

      it 'returns errors if invalid data supplied' do
        expect do
          post :create, params: {
            token: {
              logo_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              symbol: 'CAT'
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end.not_to change { Token.count }

        token = assigns[:token]
        expect(token.errors.full_messages.join(', ')).to eq("Name can't be blank")
        expect(token.logo_image).to be_a(Refile::File)
        expect(token.symbol).to eq('CAT')
      end
    end
  end

  describe '#fetch_contract_details' do
    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        post :fetch_contract_details
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in without admin flag' do
      it 'redirects to root' do
        login(account)
        post :fetch_contract_details
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in with admin flag' do
      it 'returns correct symbol and decimals for QRC20 contract' do
        stub_qtum_fetch
        post :fetch_contract_details, params: { address: '2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc', network: 'qtum_testnet' }
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(assigns[:symbol]).to eq('BIG')
        expect(assigns[:symbol]).not_to eq(nil)
      end

      it 'returns correct symbol and decimals for ERC20 contract' do
        stub_web3_fetch
        post :fetch_contract_details, params: { address: '0x6c6ee5e31d828de241282b9606c8e98ea48526e2', network: 'main' }
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(assigns[:symbol]).to eq('HOT')
        expect(assigns[:symbol]).not_to eq(nil)
      end
    end
  end

  context 'with a token' do
    let!(:cat_token) { create(:token, name: 'Cats') }
    let!(:dog_token) { create(:token, name: 'Dogs') }
    let!(:yak_token) { create(:token, name: 'Yaks') }
    let!(:fox_token) { create(:token, name: 'Foxes') }

    describe '#index' do
      context 'when not logged in' do
        it 'redirects to root' do
          session[:account_id] = nil
          get :index
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in without admin flag' do
        it 'redirects to root' do
          login(account)
          get :index
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in with admin flag' do
        it 'returns correct react component' do
          get :index
          expect(response.status).to eq(200)
          expect(assigns[:tokens].map(&:name)).to eq(%w[Cats Dogs Yaks Foxes])
        end
      end
    end

    describe '#show' do
      context 'when not logged in' do
        it 'redirects to root' do
          session[:account_id] = nil
          get :show, params: { id: cat_token.to_param }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in without admin flag' do
        it 'redirects to root' do
          login(account)
          get :show, params: { id: cat_token.to_param }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in with admin flag' do
        it 'returns correct react component' do
          get :show, params: { id: cat_token.to_param }
          expect(response.status).to eq(200)
          expect(assigns[:token]).to eq(cat_token)
        end
      end
    end

    describe '#edit' do
      context 'when not logged in' do
        it 'redirects to root' do
          session[:account_id] = nil
          get :edit, params: { id: cat_token.to_param }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in without admin flag' do
        it 'redirects to root' do
          login(account)
          get :edit, params: { id: cat_token.to_param }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in with admin flag' do
        it 'returns correct react component' do
          get :edit, params: { id: cat_token.to_param }
          expect(response.status).to eq(200)
          expect(assigns[:token]).to eq(cat_token)
        end
      end
    end

    describe '#update' do
      context 'when not logged in' do
        it 'redirects to root' do
          session[:account_id] = nil
          patch :update, params: { id: cat_token.to_param }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in without admin flag' do
        it 'redirects to root' do
          login(account)
          patch :update, params: { id: cat_token.to_param }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when logged in with admin flag' do
        it 'updates token if valid data supplied' do
          expect do
            patch :update, params: {
              id: cat_token.to_param,
              token: {
                name: 'Cat Token Updated'
              }
            }
            expect(response).to have_http_status(:ok)
            expect(response.content_type).to eq('application/json')
          end.not_to change { Token.count }

          cat_token.reload
          expect(cat_token.name).to eq('Cat Token Updated')
        end

        it 'returns errors if invalid data supplied' do
          expect do
            patch :update, params: {
              id: cat_token.to_param,
              token: {
                name: 'Dogs'
              }
            }
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq('application/json')
          end.not_to change { Token.count }

          cat_token.reload
          expect(cat_token.name).to eq('Cats')
        end
      end
    end
  end
end
