require 'rails_helper'

describe AccountsController do
  let(:authentication) { create(:sb_authentication) }
  let(:account) { authentication.account }

  describe '#update' do
    before { login(account) }
    it 'updates a valid ethereum address successfully' do
      expect do
        put :update, params: { account: { ethereum_wallet: "0x#{'a' * 40}" } }
        expect(response.status).to eq(302)
      end.to change { account.reload.ethereum_wallet }.from(nil).to("0x#{'a' * 40}")

      expect(response).to redirect_to account_url
      expect(flash[:notice]).to eq('Your account details have been updated.')
    end

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

    it 'renders errors for an invalid ethereum address' do
      expect do
        put :update, params: { account: { ethereum_wallet: 'not a valid ethereum address' } }
        expect(response.status).to eq(200)
      end.not_to change { account.reload.ethereum_wallet }

      expect(flash[:error]).to eq("Ethereum wallet should start with '0x', followed by a 40 character ethereum address")
      expect(assigns[:current_account]).to be
    end
  end

  describe '#new' do
    it 'redirect to signup page' do
      get :new
      expect(response.status).to eq 200
    end
  end

  describe '#create' do
    it 'renders errors for invalid password' do
      expect do
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
      expect do
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
      expect(response).to redirect_to root_path
    end

    it 'renders errors if email has already been taken' do
      Account.create(email: 'user@test.st', password: '12345678')
      expect do
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
      expect(flash[:notice]).to eq 'Success! Your email is confirmed.'
    end

    it 'notice about redeem award' do
      session[:redeem] = true
      get :confirm, params: { token: '1234qwer' }
      expect(new_account.reload.confirmed?).to be true
      expect(flash[:notice]).to eq 'Please click the link in your email to claim your contributor token award!'
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
      project = create(:project, ethereum_contract_address: '0x' + 'a' * 40)
      award_type = create :award_type, project: project
      create :award, award_type: award_type, account: account
      login account
    end

    it 'show account information' do
      get :show
      expect(assigns[:projects].count).to eq 1
      expect(assigns[:awards].count).to eq 1
    end
  end
end
