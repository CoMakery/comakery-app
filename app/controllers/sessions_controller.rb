class SessionsController < ApplicationController
  skip_before_action :require_login

  def oauth_failure
    flash[:error] = "Sorry, logging in failed... please try again, or email us at #{I18n.t('tech_support_email')}"
    redirect_to root_path
  end

  def create
    authentication = Authentication.find_with_omniauth(auth_hash)
    @account = authentication&.account || Authentication.create_with_omniauth!(auth_hash)
    if @account
      session[:account_id] = @account.id
    else
      flash[:error] = 'Failed authentication - Auth hash is missing one or more required values'
    end
    redirect_to redirect_path
  end

  def sign_in
    @account = Account.find_by email: params[:email]
    if @account && @account.authenticate(params[:password])
      session[:account_id] = @account.id
      flash[:notice] = 'Successful sign in'
      redirect_to redirect_path
    else
      flash[:error] = 'Invalid email or password'
      redirect_to new_session_path
    end
  end

  def destroy
    session[:account_id] = nil
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def redirect_path
    token = session[:award_token]
    if token
      session[:award_token] = nil
      confirm_award_path(token)
    else
      root_path
    end
  end
end
