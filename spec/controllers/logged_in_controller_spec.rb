require 'rails_helper'

describe LoggedInController do
  it "should get landing" do
    login_account Account.create!(provider: 'slack', uid: 'FOOO')
    get :landing
    assert_response :success
  end
end
