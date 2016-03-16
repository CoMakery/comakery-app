class SessionsController < ApplicationController
  skip_before_filter :require_login
  skip_after_action :verify_authorized, :verify_policy_scoped

  def oauth_failure
    flash[:error] = "Sorry, logging in failed... please try again, or email us at dev@comakery.com"
    redirect_to root_path
  end

  def create
    begin
      d proc { request.env['omniauth.auth'] }
      @account = Authentication.find_or_create_from_auth_hash!(request.env['omniauth.auth'])
      session[:account_id] = @account.id
      redirect_to root_path
    rescue SlackAuthHash::MissingAuthParamException
      flash['alert'] = "Failed authentication"
      redirect_to root_url
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
end
