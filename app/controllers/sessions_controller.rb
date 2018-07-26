class SessionsController < ApplicationController
  skip_before_action :require_login, :check_age
  skip_after_action :verify_authorized, :verify_policy_scoped

  def oauth_failure
    flash[:error] = "Sorry, logging in failed... please try again, or email us at #{I18n.t('tech_support_email')}"
    redirect_to root_path
  end

  def create
    authentication = Authentication.find_or_create_by_omniauth(auth_hash)
    if authentication && authentication.confirmed?
      session[:account_id] = authentication.account_id
    elsif authentication
      UserMailer.confirm_authentication(authentication).deliver_now
      flash[:error] = 'Please check your email for confirmation instruction'
      @path = root_path
    else
      flash[:error] = 'Failed authentication - Auth hash is missing one or more required values'
      @path = root_path
    end
    redirect_to redirect_path
  end

  def sign_in
    @account = Account.find_by email: params[:email]
    begin
      if @account && @account.authenticate(params[:password])
        session[:account_id] = @account.id
        flash[:notice] = 'Successful sign in'
        redirect_to redirect_path
      else
        flash[:error] = 'Invalid email or password'
        redirect_to new_session_path
      end
    rescue StandardError
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
      flash[:notice] = 'Please click the link in your email to claim your contributor token award!'
      my_project_path
    elsif @path
      @path
    else
      my_project_path
    end
  end
end
