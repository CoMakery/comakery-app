require 'rails_helper'

describe SessionsController do
  describe "routes", type: :routing do
    it "routes logout to destroy" do
      expect(get("/log_out")).to route_to("sessions#destroy")
      expect(get("/logout")).to route_to("sessions#destroy")
    end
  end

  it "should get logout" do
    get :destroy

    assert_response :redirect
    expect(response).to redirect_to(logged_out_url)
  end

  describe '#create' do
    let!(:account) { create(:account, email: "bob@example.com") }
    let!(:authentication) { create(:authentication, provider: "slack", account_id: account.id) }

    context 'with valid login credentials' do
      it 'succeeds' do
        request.env['omniauth.auth'] = {
            'name' => 'bob',
            'provider' => 'slack',
            'credentials' => {'token' => 'these are credentials'},
            'info' => {'team' => "Citizen Code", 'team_id' => 'T00000000', 'user_id' => 'U00000000', 'user' => 'redman', 'first_name' => "Red", 'last_name' => "Man"},
            'extra' => {'user_info' => {'user' => {'profile' => {'email' => "bob@example.com"}}}}}

        expect do
          post :create
        end.to change { Authentication.count }.by(1)

        assert_response :redirect
        assert_redirected_to root_path
        expect(session[:account_id]).to eq(account.id)
      end
    end

    context 'with missing credentials' do
      it 'fails' do
        request.env['omniauth.auth'] = nil

        post :create

        assert_response :redirect
        assert_redirected_to root_path
        expect(flash['alert']).not_to be_blank
        expect(session[:account_id]).to be_nil
      end
    end
  end

  describe "#oauth_failure" do
    it "redirects to logged out and shows error message" do
      get :oauth_failure

      expect(response.status).to eq(302)
      expect(flash[:error]).to match(/logging in failed/)
    end
  end
end
