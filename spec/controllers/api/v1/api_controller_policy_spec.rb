require 'rails_helper'

class DummyApiPolicyController < Api::V1::ApiController; end

describe Api::V1::ApiController do
  controller DummyApiPolicyController do
    skip_before_action :verify_signature
    skip_before_action :verify_public_key
    skip_before_action :allow_only_whitelabel
    before_action :verify_public_key_or_policy

    def index
      project_scope
      head 200
    end

    def project
      project_scope.last
    end
  end

  let(:invalid_headers) do
    {
      'API-Key' => '12345'
    }
  end

  describe 'verify_public_key_or_policy' do
    context 'comakery request without public key' do
      let!(:project) { create(:project) }

      it 'allows request with sufficient project access' do
        login project.account

        get :index, params: build(:api_signed_request, '', '/dummy_api_policy', 'GET')
        expect(response.status).to eq(200)
      end

      it 'denies request without sufficient project access'  do
        get :index, params: build(:api_signed_request, '', '/dummy_api_policy', 'GET')
        expect(response.status).to eq(401)
      end
    end

    context 'whitelabel request without public key' do
      let!(:mission) { create(:active_whitelabel_mission) }
      let!(:project) { create(:project, mission: mission) }

      it 'allows request with sufficient project access' do
        login project.account

        get :index, params: build(:api_signed_request, '', '/dummy_api_policy', 'GET')
        expect(response.status).to eq(200)
      end

      it 'denies request without sufficient project access'  do
        get :index, params: build(:api_signed_request, '', '/dummy_api_policy', 'GET')
        expect(response.status).to eq(401)
      end
    end

    context 'whitelabel request with incorrect public key' do
      before do
        create(:active_whitelabel_mission)
      end

      it 'denies request' do
        request.headers.merge! invalid_headers

        get :index, params: build(:api_signed_request, '', '/dummy_api_policy', 'GET')
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'current_account' do
    let(:account) { create(:account) }

    before do
      login account
    end

    it 'returns request account stored in session' do
      expect(controller.current_account).to eq(account)
    end
  end
end
