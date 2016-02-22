class LoggedOutController < ApplicationController
  skip_before_filter :require_login
  before_filter :skip_authorization
  layout 'layouts/logged_out'

  def show
  end

  def not_found
    redirect_to root_url
  end
end
