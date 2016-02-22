require 'rails_helper'

describe LoggedOutController do
  describe "routes", type: :routing do
    it "routes logout to destroy" do
      expect(get("/home")).to route_to("logged_out#show")
    end
  end

  describe 'show' do
    it 'should get show' do
      get :show

      expect(response).to be_success
    end
  end
end
