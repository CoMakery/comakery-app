require 'rails_helper'

describe PasswordResetsController do
  let!(:account) { create(:account, email: 'user@test.st') }

  describe '#new' do
    it 'redirect to reset password page' do
      get :new
      expect(response.status).to eq 200
    end
  end

  describe '#create' do
    it 'render error if email does not exist' do
      post :create, params: { email: 'acb@somthing.com' }
      expect(account.reset_password_token).to be nil
      expect(flash[:error]).to eq 'Could not found account with given email'
    end
    it 'create reset password token for account' do
      post :create, params: { email: 'user@test.st' }
      expect(account.reload.reset_password_token).not_to be nil
      expect(flash[:notice]).to eq 'please check your email for reset password instructions'
      expect(response).to redirect_to root_path
    end
  end

  describe '#edit' do
    before do
      account.update reset_password_token: '1234'
    end
    it 'render error for invalid token' do
      get :edit, params: { id: 'invalidtoken' }
      expect(flash[:error]).to eq 'Invalid reset password token'
      expect(response).to redirect_to root_path
    end

    it 'redirect to signup page' do
      get :edit, params: { id: '1234' }
      expect(assigns[:account].email).to eq account.email
      expect(response.status).to eq 200
    end
  end

  describe '#update' do
    before do
      account.update reset_password_token: '1234'
    end
    it 'render error for invalid token' do
      put :update, params: { id: 'invalidtoken', account: { password: '12345678' } }
      expect(flash[:error]).to eq 'Invalid reset password token'
      expect(response).to redirect_to root_path
    end

    it 'render error for invalid password' do
      put :update, params: { id: '1234', account: { password: 'short' } }
      expect(assigns[:account].errors.full_messages.first).to eq 'Password is too short (minimum is 8 characters)'
    end

    it 'set new password for account' do
      put :update, params: { id: '1234', account: { password: '12345678' } }
      expect(flash[:notice]).to eq 'Successful reset password'
      expect(account.reload.authenticate('12345678')).to be_truthy
      expect(response).to redirect_to root_path
    end
  end
end
