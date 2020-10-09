require 'rails_helper'

describe AccountsController do
  let(:authentication) { create(:sb_authentication) }
  let(:account) { authentication.account }

  describe '#update' do
    before { login(account) }

    it 'set account to unconfirm status if change email' do
      put :update, params: { account: { email: 'another@test.st' } }
      expect(response.status).to eq(302)
      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq('Your account details have been updated.')
      account.reload
      expect(account.email).to eq 'another@test.st'
      expect(account.confirmed?).to be_falsey
    end

    it 'send email to admin notice about underage' do
      account.update date_of_birth: '2010-01-01'
      put :update, params: { account: { date_of_birth: '01/01/1900' } }
      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq('Your account details have been updated.')
    end
  end

  describe '#new' do
    it 'redirect to signup page' do
      get :new
      expect(response.status).to eq 200
    end

    it 'redirects to my_project_path if user already signed in' do
      login(account)
      get :new
      expect(response).to redirect_to my_project_path
    end
  end

  describe '#create' do
    it 'renders errors for invalid password' do
      expect do # rubocop:todo Lint/AmbiguousBlockAssociation
        post :create, params: {
          account: {
            email: 'user@test.st',
            password: '1'
          }
        }
        expect(response.status).to eq(200)
      end.not_to change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq 'Password is too short (minimum is 8 characters)'
    end

    it 'renders errors if email is blank' do
      expect do # rubocop:todo Lint/AmbiguousBlockAssociation
        post :create, params: {
          account: {
            email: '',
            password: '1234678'
          }
        }
        expect(response.status).to eq(200)
      end.not_to change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq "Email can't be blank"
    end

    it 'sign up for new account' do
      expect do
        post :create, params: {
          account: {
            email: 'user@test.st',
            first_name: 'User',
            last_name: 'Tester',
            date_of_birth: '01/01/2000',
            country: 'America',
            password: '12345678'
          }
        }
        expect(response.status).to eq(302)
      end.to change { Account.count }.by(1)

      expect(Account.last.managed_mission_id).to be_nil
      expect(Account.last.managed_account_id).to be_nil

      expect(response).to redirect_to build_profile_accounts_path
    end

    it 'sets managed_mission_id and managed_account_id when accessed from whitelabel domain' do
      active_whitelabel_mission = create(:active_whitelabel_mission)

      expect do
        post :create, params: {
          account: {
            email: 'user@test.st',
            first_name: 'User',
            last_name: 'Tester',
            date_of_birth: '01/01/2000',
            country: 'America',
            password: '12345678'
          }
        }
        expect(response.status).to eq(302)
      end.to change { Account.count }.by(1)

      expect(Account.last.managed_mission_id).to eq(active_whitelabel_mission.id)
      expect(Account.last.managed_account_id).not_to be_nil

      expect(response).to redirect_to build_profile_accounts_path
    end

    it 'adds default interest in auto add interest projects' do
      project_auto_add1 = create(:project, auto_add_interest: true)
      project_auto_add2 = create(:project, auto_add_interest: true)
      create(:project)
      post :create, params: {
        account: {
          email: 'user-yo@test.st',
          first_name: 'User',
          last_name: 'Tester',
          date_of_birth: '01/01/2000',
          country: 'America',
          password: '12345678'
        }
      }

      account = Account.where(email: 'user-yo@test.st').last
      expect(account.projects_interested).to contain_exactly(project_auto_add1, project_auto_add2)
    end

    it 'adds nothing if there are no auto add interest projects' do
      create(:project)
      create(:project)

      post :create, params: {
        account: {
          email: 'user-yo@test.st',
          first_name: 'User',
          last_name: 'Tester',
          date_of_birth: '01/01/2000',
          country: 'America',
          password: '12345678'
        }
      }

      account = Account.where(email: 'user-yo@test.st').last
      expect(account.projects_interested).to eq([])
    end

    it 'renders errors if email has already been taken' do
      Account.create(email: 'user@test.st', password: '12345678')
      expect do # rubocop:todo Lint/AmbiguousBlockAssociation
        post :create, params: {
          account: {
            email: 'user@test.st',
            first_name: 'User',
            last_name: 'Tester',
            password: '12345678'
          }
        }
        expect(response.status).to eq(200)
      end.not_to change { Account.count }
      new_account = assigns[:account]
      expect(new_account.errors.full_messages.first).to eq 'Email has already been taken'
    end

    it 'redirects to my_project_path if user already signed in' do
      login(account)
      post :create, params: {
        account: {
          email: 'user@test.st',
          password: '1'
        }
      }
      expect(response).to redirect_to my_project_path
    end
  end

  describe '#confirm' do
    let!(:new_account) { create(:account, email: 'user@test.st', email_confirm_token: '1234qwer') }

    it 'render errors for invalid confirmation token' do
      get :confirm, params: { token: 'invalid token' }
      expect(new_account.confirmed?).to be false
      expect(flash[:error]).to eq 'Invalid token'
    end

    it 'confirm user email with given token' do
      get :confirm, params: { token: '1234qwer' }
      expect(new_account.reload.confirmed?).to be true
      expect(response).to redirect_to my_tasks_path
    end

    it 'notice about redeem award' do
      session[:redeem] = true
      get :confirm, params: { token: '1234qwer' }
      expect(new_account.reload.confirmed?).to be true
      expect(flash[:notice]).to eq 'Please click the link in your email to claim your contributor token award!'
      expect(response).to redirect_to my_tasks_path
    end
  end

  describe '#update_profile' do
    let!(:authentication) { create(:authentication, confirm_token: '1234qwer') }

    before { login(account) }

    it 'updates profile with valid params' do
      post :update_profile, params: {
        account: {
          first_name: 'Update',
          last_name: 'Profile',
          country: 'United Kingdom'
        }
      }
      expect(response).to redirect_to my_tasks_path
    end

    it 'renders errors for invalid params' do
      post :update_profile, params: {
        account: {
          first_name: nil,
          last_name: nil
        }
      }
      expect(flash[:error]).to eq("First name can't be blank, Last name can't be blank")
    end

    it 'updates profile with valid params for an un-confirmed authentication' do
      session[:authentication_id] = authentication.id
      post :update_profile, params: {
        account: {
          first_name: 'Update',
          last_name: 'Profile',
          country: 'United Kingdom'
        }
      }
      expect(response).to redirect_to my_tasks_path
      expect(assigns[:current_account]).to eq nil
    end

    it 'triggers email confirmation if email is updated' do
      post :update_profile, params: {
        account: {
          email: 'new_email@comakery.com'
        }
      }
      expect(response).to redirect_to my_tasks_path
      expect(account.reload.email_confirm_token).not_to be_nil
    end
  end

  describe '#confirm_authentication' do
    let!(:authentication) { create(:authentication, confirm_token: '1234qwer') }

    it 'render errors for invalid confirmation token' do
      get :confirm_authentication, params: { token: 'invalid token' }
      expect(authentication.confirmed?).to be false
      expect(flash[:error]).to eq 'Invalid token'
    end

    it 'confirm user email with given token' do
      get :confirm_authentication, params: { token: '1234qwer' }
      expect(authentication.reload.confirmed?).to be true
      expect(flash[:notice]).to eq 'Success! Your email is confirmed.'
    end
  end

  describe '#download_data' do
    before { login(account) }

    it 'download_data' do
      get :download_data, params: { format: 'zip' }
    end
  end

  describe '#show' do
    before do
      stub_token_symbol
      project = create(:project, token: create(:token, contract_address: '0x' + 'a' * 40))
      award_type = create :award_type, project: project
      create :award, award_type: award_type, account: account
      login account
    end

    it 'show account information' do
      get :show
      expect(assigns[:projects][0]['id']).to eq Project.last.id
      expect(assigns[:awards].count).to eq 1
    end
  end
end
