require 'rails_helper'

describe SessionsController do
  describe 'routes', type: :routing do
    it 'routes logout to destroy' do
      expect(get('/logout')).to route_to('sessions#destroy')
    end
  end

  it 'gets logout' do
    get :destroy

    assert_response :redirect
    expect(response).to redirect_to(root_path)
  end

  describe '#create' do
    let!(:account) { create(:account, email: 'bob@example.com') }
    let!(:authentication) { create(:authentication, provider: 'slack', account_id: account.id) }
    let!(:auth_hash) do
      {
        'uid'=>'U9GATGPFH',
        'name' => 'bob johnson',
        'provider' => 'slack',
        'credentials' => { 'token' => 'these are credentials' },
        'info' => { 'email' => 'bob@example.com', 'team' => 'Citizen Code', 'team_id' => 'this_is_a_team_id', 'user_id' => 'U00000000', 'user' => 'redman', 'first_name' => 'Red', 'last_name' => 'Man', 'team_domain' => 'citizencode' },
        'extra' => {
          'user_info' => { 'user' => { 'profile' => { 'email' => 'bob@example.com', 'image_32' => 'https://avatars.com/avatars_32.jpg' }, 'real_name' => 'Real Name' } },
          'team_info' => { 'team' => { 'icon' => { 'image_34' => 'https://slack.example.com/team-image-34-px.jpg', 'image_132' => 'https://slack.example.com/team-image-132-px.jpg' } } }
        }
      }
    end

    context 'with valid login credentials' do
      it 'succeeds' do
        request.env['omniauth.auth'] = auth_hash

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
        request.env['omniauth.auth'] = { 'provider' => 'slack', 'credentials' => { 'token' => 'this is a token' } }

        post :create

        assert_response :redirect
        assert_redirected_to root_path
        expect(flash[:error]).to eq('Failed authentication - Auth hash is missing one or more required values')
        expect(session[:account_id]).to be_nil
      end
    end

    context 'when slack instances have been white-listed' do
      before { expect(ENV).to receive(:[]).with('BETA_SLACK_INSTANCE_WHITELIST').and_return('foo,comakery') }

      it 'prevents users from non-whitelisted slack instances from logging in, saves the info in a beta-signup' do
        expect(auth_hash['info']['team_domain']).to eq('citizencode')
        request.env['omniauth.auth'] = auth_hash

        expect do
          post :create
        end.to change { BetaSignup.count }.by(1)

        expect(session[:account_id]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to new_beta_signup_url(email_address: 'bob@example.com')

        beta_signup = BetaSignup.last
        expect(beta_signup.email_address).to eq('bob@example.com')
        expect(beta_signup.name).to eq('Real Name')
        expect(beta_signup.slack_instance).to eq('citizencode')
        expect(beta_signup.oauth_response).to eq(auth_hash)
        expect(beta_signup.opt_in).to eq(false)
      end
    end

    context 'when slack instances whitelisting is blank' do
      before { expect(ENV).to receive(:[]).with('BETA_SLACK_INSTANCE_WHITELIST').and_return('') }

      it 'succeeds' do
        request.env['omniauth.auth'] = auth_hash

        post :create

        assert_response :redirect
        assert_redirected_to root_path
        expect(session[:account_id]).to eq(account.id)
      end
    end

    context 'when slack instances whitelisting matches the user logging in' do
      before { expect(ENV).to receive(:[]).with('BETA_SLACK_INSTANCE_WHITELIST').and_return('citizencode') }

      it 'succeeds' do
        request.env['omniauth.auth'] = auth_hash
        expect(auth_hash['info']['team_domain']).to eq('citizencode')

        post :create

        assert_response :redirect
        assert_redirected_to root_path
        expect(session[:account_id]).to eq(account.id)
      end
    end
  end

  describe '#oauth_failure' do
    it 'redirects to logged out and shows error message' do
      get :oauth_failure

      expect(response.status).to eq(302)
      expect(flash[:error]).to match(/logging in failed/)
    end
  end

  describe '#sign_in' do
    let!(:account) { create(:account, email: 'user@example.com', password: '12345678') }

    it 'prevent login with invalid account' do
      post :sign_in, params: { email: 'user@example.com', password: 'invalid' }
      expect(flash[:error]).to eq 'Invalid email or password'
      expect(response).to redirect_to new_session_path
    end

    it 'allow valid user to login' do
      post :sign_in, params: { email: 'user@example.com', password: '12345678' }
      expect(flash[:notice]).to eq 'Successful sign in'
      expect(response).to redirect_to root_path
    end
  end
end
