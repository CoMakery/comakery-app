class SessionsController < ApplicationController
  skip_before_filter :require_login
  skip_after_action :verify_authorized # should be fixed
  skip_after_action :verify_policy_scoped # should be fixed

  layout 'layouts/logged_out'

  def create
    @account = Authentication.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    if @account
      session[:account_id] = @account.id
      redirect_to root_path
    else
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
