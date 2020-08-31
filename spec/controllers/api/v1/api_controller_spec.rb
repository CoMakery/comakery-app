require 'rails_helper'

class DummyApiController < Api::V1::ApiController; end

describe Api::V1::ApiController do
  controller DummyApiController do
    def index
      project_scope
      head 200
    end
  end

  let(:valid_headers) do
    {
      'API-Key' => build(:api_key)
    }
  end

  let(:invalid_headers) do
    {
      'API-Key' => '12345'
    }
  end

  before do
    request.headers.merge! valid_headers
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
      whitelabel_mission.update(whitelabel_domain: 'test.host', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key))

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
