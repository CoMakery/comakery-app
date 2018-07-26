class PagesController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def landing
    redirect_to mine_project_path if current_account
  end
end
