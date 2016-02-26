require 'rails_helper'

describe LoggedOutController do
  describe "routes", type: :routing do
    it "routes logout to destroy" do
      expect(get("/home")).to route_to("logged_out#show")
    end
  end

  describe 'show' do
    it 'should get show if you are not logged in' do
      get :show

      expect(response).to be_success
    end

    it 'should redirects you to projects index if you are logged in' do
      login(create(:account))

      get :show

      expect(response.status).to eq(302)
      expect(response).to redirect_to(projects_url)
    end
  end
end
