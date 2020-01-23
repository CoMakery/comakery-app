require 'rails_helper'

class DummyApiController < Api::V1::ApiController; end

describe Api::V1::ApiController do
  controller DummyApiController do
    def index
      project_scope
      head 200
    end
  end

  describe 'allow_only_whitelabel' do
    it 'available for whitelabel requests' do
      create(:active_whitelabel_mission)

      get :index, params: build(:api_signed_request, '', '/dummy_api', 'GET')
      expect(response.status).to eq(200)
    end

    it 'unavailable for non-whitelabel requests' do
      get :index
      expect(response.status).to eq(404)
    end
  end

  describe 'verify_signature' do
    it 'denies requests with incorrect signature' do
      create(:active_whitelabel_mission)

      params = build(:api_signed_request, '', '/dummy_api', 'GET')
      params['proof']['signature'] = 'wrong'

      get :index, params: params
      expect(response.status).to eq(401)
    end

    it 'denies requests with non-unique nonce' do
      mission = create(:active_whitelabel_mission)

      params = build(:api_signed_request, '', '/dummy_api', 'GET')
      Rails.cache.write("api::v1::nonce_history:#{mission.id}:#{params['body']['nonce']}", true, expires_in: 1.day)

      get :index, params: params
      expect(response.status).to eq(401)
    end
  end

  describe 'current_domain' do
    it 'returns request domain including all subdomains' do
      expect(controller.current_domain).to eq('test.host')
    end
  end

  describe 'whitelabel_mission' do
    it 'assigns whitelabel mission which matches current_domain' do
      active_whitelabel_mission = create(:active_whitelabel_mission)

      get :index
      expect(assigns[:whitelabel_mission]).to eq(active_whitelabel_mission)
    end

    it 'doesnt assign whitelabel mission' do
      get :index
      expect(assigns[:whitelabel_mission]).to be_nil
    end
  end

  describe 'project_scope' do
    let!(:whitelabel_mission) { create(:mission, whitelabel: true) }
    let!(:whitelabel_project) { create(:project, mission: whitelabel_mission) }
    let!(:project) { create(:project) }

    it 'sets project scope to whitelabel_mission projects' do
      whitelabel_mission.update(whitelabel_domain: 'test.host', whitelabel_api_public_key: build(:api_public_key))

      get :index, params: build(:api_signed_request, '', '/dummy_api', 'GET')
      expect(assigns[:project_scope].all).to include(whitelabel_project)
      expect(assigns[:project_scope].all).not_to include(project)
    end

    it 'doesnt set project_scope for non-whitelabel requests ' do
      get :index
      expect(assigns[:project_scope]).to be_nil
    end
  end
end
