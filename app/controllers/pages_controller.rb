class PagesController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def landing
    render :home if current_account
  end

  def home; end
end
