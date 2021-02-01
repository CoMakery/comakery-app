require 'rails_helper'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'

RSpec.describe Api::V1::HotWalletAddressesController, type: :controller do
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_signature'
  it_behaves_like 'requires_whitelabel_mission'
  it_behaves_like 'authorizable_by_mission_key'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }

  let(:valid_attributes) do
    {
      name: build(:wallet).name,
      address: build(:wallet).address,
      _blockchain: build(:wallet)._blockchain
    }
  end

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'POST #create', vcr: true do
    let(:create_params) { { hot_wallet: valid_attributes } }

    context 'with valid params' do
      it 'returns created hot_wallet' do
        params = build(:api_signed_request, create_params, api_v1_project_hot_wallet_addresses_path(project_id: project.id), 'POST')
        params[:project_id] = project.id
        params[:format] = :json

        post :create, params: params
        expect(response).to have_http_status(:created)
        expect(project.reload.hot_wallet.present?).to be true
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { hot_wallet: valid_attributes.merge(address: 'invalid') } }

      it 'returns an error' do
        params = build(:api_signed_request, invalid_params, api_v1_project_hot_wallet_addresses_path(project_id: project.id), 'POST')
        params[:project_id] = project.id
        params[:format] = :json

        post :create, params: params
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when project has already an assigned hot wallet' do
      before do
        create(:wallet, source: :hot_wallet, project_id: project.id)
      end

      it 'returns an error' do
        params = build(:api_signed_request, create_params, api_v1_project_hot_wallet_addresses_path(project_id: project.id), 'POST')
        params[:project_id] = project.id
        params[:format] = :json

        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
