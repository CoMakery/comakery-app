require 'rails_helper'

describe SessionsController do
  it "should get logout" do
    get :destroy
    assert_response :redirect
  end

  describe '#create' do
    let!(:account) { create(:account, email: "bob@example.com") }
    let!(:authentication) { create(:authentication, provider: "slack", uid: "FOOOO", account_id: account.id) }

    context 'with valid login credentials' do
      it 'succeeds' do
        request.env['omniauth.auth'] = {'provider' => 'slack', 'uid' => 'FOOOO', 'extra' => {'user_info' => {'user' => {'profile' => {'email' => "bob@example.com"}}}}}

        post :create

        assert_response :redirect
        assert_redirected_to my_account_path
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
end
