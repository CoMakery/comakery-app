class PagesController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def landing
    if current_account
      if current_account.finished_contributor_form?
        render :featured
      else
        render :home
      end
    end
  end

  def home; end

  def featured; end
end
