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

  def featured
    current_account.update contributor_form: true unless current_account.finished_contributor_form?
  end

  def add_interest
    @interest = current_user.interests.new
    @interest.project = params[:project]
    @interest.protocol = params[:protocol_interest]
    @interest.save
    respond_to :js
  end
end
