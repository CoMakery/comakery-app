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

      get :index
      expect(response.status).to eq(200)
    end

    it 'unavailable for non-whitelabel requests' do
      get :index
      expect(response.status).to eq(404)
    end
  end

  describe 'current_domain' do
    it 'returds request domain including all subdomains' do
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
      whitelabel_mission.update(whitelabel_domain: 'test.host')

      get :index
      expect(assigns[:project_scope].all).to include(whitelabel_project)
      expect(assigns[:project_scope].all).not_to include(project)
    end

    it 'doesnt set project_scope for non-whitelabel requests ' do
      get :index
      expect(assigns[:project_scope]).to be_nil
    end
  end
end
