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
    let!(:auth_hash) do
      {
        'uid' => 'U9GATGPFH',
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
      let!(:account2) { create(:account, email: 'bob2@example.com') }

      it 'create authentication from slack' do
        request.env['omniauth.auth'] = auth_hash

        expect do
          post :create
        end.to change { Authentication.count }.by(1)
        auth = Authentication.last
        expect(auth.confirmed?).to eq false
        expect(flash[:error]).to eq 'Please check your email for confirmation instruction'
        assert_response :redirect
        assert_redirected_to my_tasks_path
      end

      it 'create authentication from discord' do
        auth_hash['provider'] = 'discord'
        request.env['omniauth.auth'] = auth_hash

        expect do
          post :create
        end.to change { Authentication.count }.by(1)
        auth = Authentication.last
        expect(auth.confirmed?).to eq false
        expect(flash[:error]).to eq 'Please check your email for confirmation instruction'
        assert_response :redirect
        assert_redirected_to my_tasks_path
      end

      it 'login confirmed authentication' do
        create :authentication, uid: 'U9GATGPFH', account: account
        request.env['omniauth.auth'] = auth_hash
        post :create
        auth = Authentication.last
        expect(auth.confirmed?).to eq true
        expect(session[:account_id]).to eq account.id
        assert_response :redirect
        assert_redirected_to root_path
      end

      it 'create new un-confirmed authentication' do
        create :authentication, uid: 'another_id_same_email', account: account
        request.env['omniauth.auth'] = auth_hash

        expect do
          post :create
        end.to change { Authentication.count }.by(1)
        auth = Authentication.last
        expect(auth.confirmed?).to eq false
        expect(flash[:error]).to eq 'Please check your email for confirmation instruction'
        assert_response :redirect
        assert_redirected_to my_tasks_path
      end

      it 'login authentication with an account that missing email' do
        account2.update_columns email: nil # rubocop:disable Rails/SkipsModelValidations
        create :authentication, uid: 'another_id_same_email', account: account2, confirm_token: SecureRandom.hex
        request.env['omniauth.auth'] = auth_hash.merge('uid' => 'another_id_same_email')

        expect do
          post :create
        end.to change { Authentication.count }.by(0)
        auth = Authentication.last
        expect(auth.confirmed?).to eq false
        assert_response :redirect
        assert_redirected_to build_profile_accounts_path
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

    it 'redirects to new_session_path with error when email is missing from discord oauth' do
      auth_hash['provider'] = 'discord'
      auth_hash['info']['email'] = nil

      request.env['omniauth.auth'] = auth_hash
      post :create

      assert_response :redirect
      assert_redirected_to new_session_path
      expect(flash[:error]).to eq('Please use Discord account with a valid email address')
      expect(session[:account_id]).to be_nil
    end

    it 'redirects to my_project_path if user already signed in' do
      login(account)
      get :create
      expect(response).to redirect_to my_project_path
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
    let!(:account1) { create(:account, email: 'user1@example.com', password: '12345678', email_confirm_token: '1234') }
    let!(:account2) { create(:account, email: 'user2@example.com', password: nil) }
    let(:project) { create(:project, account: account1, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'eth', _blockchain: :ethereum_ropsten)) }

    it 'allows to login with managed account on according whitelabel instance' do
      active_whitelabel_mission = create(:active_whitelabel_mission)
      account = create(:account, managed_mission: active_whitelabel_mission, password: '12345678')

      post :sign_in, params: { email: account.email, password: '12345678' }
      expect(response).to redirect_to projects_path
    end

    it 'doesnt allow to login with managed account on a different whitelabel instance' do
      create(:active_whitelabel_mission)
      whitelabel_mission = create(:mission, whitelabel: true, whitelabel_domain: 'dummy')
      account = create(:account, managed_mission: whitelabel_mission, password: '12345678')

      post :sign_in, params: { email: account.email, password: '12345678' }
      expect(flash[:error]).to eq 'Invalid email or password'
      expect(response).to redirect_to new_session_path
    end

    it 'doesnt allow to login with managed account on comakery' do
      whitelabel_mission = create(:mission, whitelabel: true, whitelabel_domain: 'dummy')
      account = create(:account, managed_mission: whitelabel_mission, password: '12345678')

      post :sign_in, params: { email: account.email, password: '12345678' }
      expect(flash[:error]).to eq 'Invalid email or password'
      expect(response).to redirect_to new_session_path
    end

    it 'doesnt allow to login with comakery account on a whitelabel instance' do
      create(:active_whitelabel_mission)

      post :sign_in, params: { email: 'user@example.com', password: 'invalid' }
      expect(flash[:error]).to eq 'Invalid email or password'
      expect(response).to redirect_to new_session_path
    end

    it 'prevent login with wrong password' do
      post :sign_in, params: { email: 'user@example.com', password: 'invalid' }
      expect(flash[:error]).to eq 'Invalid email or password'
      expect(response).to redirect_to new_session_path
    end

    it 'allow valid user to login' do
      post :sign_in, params: { email: 'user@example.com', password: '12345678' }
      expect(response).to redirect_to root_path
    end

    it 'catch for error for account without password' do
      post :sign_in, params: { email: 'user2@example.com', password: '12345678' }
      expect(flash[:error]).to eq 'Invalid email or password'
      expect(response).to redirect_to new_session_path
    end

    it 'notice to redeem award' do
      session[:redeem] = true
      post :sign_in, params: { email: 'user@example.com', password: '12345678' }
      expect(flash[:notice]).to eq 'Please click the link in your email to claim your contributor token award!'
      expect(response).to redirect_to my_tasks_path
    end

    it 'notice to update ethereum_wallet and redirect to my projects' do
      account.update new_award_notice: true, ethereum_wallet: nil
      account.projects << project
      create(:award, award_type: create(:award_type, project: project), account: account)
      post :sign_in, params: { email: 'user@example.com', password: '12345678' }
      expect(flash[:notice]).to eq 'Congratulations, you just claimed your award! Be sure to enter your Ethereum Address on your <a href="/account">account page</a> to receive your tokens.'
      expect(response).to redirect_to my_project_path
    end

    it 'notice new award and redirect to my projects' do
      account.update new_award_notice: true, ethereum_wallet: '0x' + 'a' * 40
      account.projects << project
      create(:award, award_type: create(:award_type, project: project), account: account)
      post :sign_in, params: { email: 'user@example.com', password: '12345678' }
      expect(flash[:notice]).to include 'Congratulations, you just claimed your award! Your Ethereum address is'
      expect(response).to redirect_to my_project_path
    end

    it 'redirects to my_project_path if user already signed in' do
      login(account)
      post :sign_in, params: { email: 'user@example.com', password: '12345678' }
      expect(response).to redirect_to my_project_path
    end

    context 'on Qtum network' do
      let(:project2) { create(:project, account: account1, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'qtum', _blockchain: 'qtum')) }

      it 'notice to update qtm_wallet' do
        account.update new_award_notice: true
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to eq 'Congratulations, you just claimed your award! Be sure to enter your Qtum Address on your <a href="/account">account page</a> to receive your tokens.'
        expect(response).to redirect_to my_project_path
      end

      it 'notice new award' do
        account.update new_award_notice: true, qtum_wallet: 'Q' + 'a' * 33
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to include 'Congratulations, you just claimed your award! Your Qtum address is'
        expect(response).to redirect_to my_project_path
      end
    end

    context 'on Cardano network' do
      let(:project2) { create(:project, account: account1, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'ada', _blockchain: 'cardano')) }

      it 'notice to update cardano_wallet' do
        account.update new_award_notice: true
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to eq 'Congratulations, you just claimed your award! Be sure to enter your Cardano Address on your <a href="/account">account page</a> to receive your tokens.'
        expect(response).to redirect_to my_project_path
      end

      it 'notice new award' do
        account.update new_award_notice: true, cardano_wallet: 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp'
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to include 'Congratulations, you just claimed your award! Your Cardano address is'
        expect(response).to redirect_to my_project_path
      end
    end

    context 'on Bitcoin network' do
      let(:project2) { create(:project, account: account1, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'btc')) }

      it 'notice to update bitcoin_wallet' do
        account.update new_award_notice: true
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to eq 'Congratulations, you just claimed your award! Be sure to enter your Bitcoin Address on your <a href="/account">account page</a> to receive your tokens.'
        expect(response).to redirect_to my_project_path
      end

      it 'notice new award' do
        account.update new_award_notice: true, bitcoin_wallet: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to include 'Congratulations, you just claimed your award! Your Bitcoin address is'
        expect(response).to redirect_to my_project_path
      end
    end

    context 'on EOS network' do
      let(:project2) { create(:project, account: account1, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'eos', _blockchain: 'eos')) }

      it 'notice to update eos_wallet' do
        account.update new_award_notice: true
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to eq 'Congratulations, you just claimed your award! Be sure to enter your EOS account name on your <a href="/account">account page</a> to receive your tokens.'
        expect(response).to redirect_to my_project_path
      end

      it 'notice new award' do
        account.update new_award_notice: true, eos_wallet: 'aaatestnet11'
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to include 'Congratulations, you just claimed your award! Your EOS account name is'
        expect(response).to redirect_to my_project_path
      end
    end

    context 'on Tezos network' do
      let(:project2) { create(:project, account: account1, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'xtz', _blockchain: 'tezos')) }

      it 'notice to update tezos_wallet' do
        account.update new_award_notice: true
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to eq 'Congratulations, you just claimed your award! Be sure to enter your Tezos Address on your <a href="/account">account page</a> to receive your tokens.'
        expect(response).to redirect_to my_project_path
      end

      it 'notice new award' do
        account.update new_award_notice: true, tezos_wallet: 'tz1Zbe9hjjSnJN2U51E5W5fyRDqPCqWMCFN9'
        account.projects << project2
        create(:award, award_type: create(:award_type, project: project2), account: account)
        post :sign_in, params: { email: 'user@example.com', password: '12345678' }
        expect(flash[:notice]).to include 'Congratulations, you just claimed your award! Your Tezos address is'
        expect(response).to redirect_to my_project_path
      end
    end
  end
end
