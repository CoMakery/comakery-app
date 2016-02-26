class LoggedOutController < ApplicationController
  skip_before_filter :require_login
  before_filter :skip_authorization
  layout 'layouts/logged_out'

  def show
    redirect_to projects_url if session[:account_id]
  end

  def not_found
    redirect_to root_url
  end
end
