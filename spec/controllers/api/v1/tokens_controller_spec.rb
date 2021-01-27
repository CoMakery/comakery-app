require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::TokensController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_signature'
  it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:cat_token) { create(:token, name: 'Cats') }
  let!(:dog_token) { create(:token, name: 'Dogs', _blockchain: 'cardano') }
  let!(:yak_token) { create(:token, name: 'Yaks') }
  let!(:fox_token) { create(:token, name: 'Foxes') }

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'GET #index' do
    context 'fetch tokens without filtering' do
      it 'returns tokens' do
        params = build(:api_signed_request, '', api_v1_tokens_path, 'GET')
        params[:format] = :json

        get :index, params: params
        expect(response).to be_successful
      end
    end

    context 'filter tokens with OR operator' do
      it 'returns filtered tokens' do
        params = build(:api_signed_request, '', api_v1_tokens_path, 'GET')
        params[:q] = { name_or_symbol_cont: 'Cats' }
        params[:format] = :json

        get :index, params: params
        expect(response).to be_successful
        expect(assigns[:tokens].map(&:name)).to eq(['Cats'])
      end
    end

    context 'filter tokens with AND operator' do
      it 'returns filtered tokens' do
        params = build(:api_signed_request, '', api_v1_tokens_path, 'GET')
        params[:q] = { name_cont: 'Dogs', network_eq: 'cardano' }
        params[:format] = :json

        get :index, params: params
        expect(response).to be_successful
        expect(assigns[:tokens].map(&:name)).to eq(['Dogs'])
      end
    end

    context 'with invalid params' do
      it 'renders an error' do
        params = build(:api_signed_request, '', api_v1_tokens_path, 'GET')
        params[:q] = { network_cont: 'bitcoin' }
        params[:format] = :json

        get :index, params: params
        expect(response).not_to be_successful
        expect(assigns[:errors]).not_to be_nil
      end
    end
  end
end
