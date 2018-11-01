class PagesController < ApplicationController
  skip_before_action :require_login, except: [:featured, :home]
  skip_after_action :verify_authorized, except: [:featured, :home]

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
    @interest.protocol = params[:protocol]
    @interest.save
    respond_to do |format|
      format.json {render json: @interest.to_json  }
    end
  end
end
