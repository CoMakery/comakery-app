require 'rails_helper'
require 'controllers/api/v1/concerns/authorizable_by_mission_key_spec'
require 'controllers/api/v1/concerns/requires_an_authorization_spec'
require 'controllers/api/v1/concerns/requires_signature_spec'
require 'controllers/api/v1/concerns/requires_whitelabel_mission_spec'

RSpec.describe Api::V1::AccountTransfersController, type: :controller do
  it_behaves_like 'authorizable_by_mission_key'
  it_behaves_like 'requires_an_authorization'
  it_behaves_like 'requires_signature'
  it_behaves_like 'requires_whitelabel_mission'

  let!(:active_whitelabel_mission) { create(:active_whitelabel_mission) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }
  let!(:project) { create(:project, mission: active_whitelabel_mission) }
  let!(:transfer) { create(:award, account: account, project: project) }

  before do
    allow(controller).to receive(:authorized).and_return(true)
  end

  describe 'GET #index' do
    it 'returns transfers' do
      params = build(:api_signed_request, '', api_v1_account_transfers_path(account_id: account.managed_account_id), 'GET')
      params[:account_id] = account.managed_account_id
      params[:format] = :json

      get :index, params: params
      expect(response).to be_successful
      expect(assigns[:transfers]).to eq([transfer])
    end

    it 'applies pagination' do
      params = build(:api_signed_request, '', api_v1_account_transfers_path(account_id: account.managed_account_id), 'GET')
      params.merge!(account_id: account.managed_account_id, format: :json, page: 9999)

      get :index, params: params
      expect(response).to be_successful
      expect(assigns[:transfers]).to eq([])
    end
  end
end
