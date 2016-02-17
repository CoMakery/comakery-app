class SessionsController < ApplicationController
  skip_before_filter :require_login
  layout 'layouts/logged_out'

  def create
    @account = Authentication.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    if @account
      session[:account_id] = @account.id
      redirect_to my_account_url
    else
      flash['alert'] = "Failed authentication"
      redirect_to root_url
    end
  end

  def destroy
    session[:account_id] = nil
    redirect_to root_path, notice: "You have been logged out."
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
