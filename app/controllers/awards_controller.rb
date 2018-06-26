class AwardsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :update_transaction_address

  before_action :assign_project, only: %i[create index update_transaction_address]
  skip_before_action :require_login, only: %i[index confirm update_transaction_address]

  def index
    @awards = @project.awards
    @awards = @awards.where(account_id: current_account.id) if current_account && params[:mine] == 'true'
    @awards = @awards.order(created_at: :desc).page(params[:page]).decorate
  end

  def create
    result = AwardSlackUser.call(project: @project, issuer: current_account, award_type_id: params[:award][:award_type_id], channel_id: params[:award][:channel_id], award_params: award_params)
    if result.success?
      award = result.award
      award.save!
      award.send_award_notifications if award.channel
      award.send_confirm_email
      flash[:notice] = "Successfully sent award to #{award.decorate.recipient_display_name}"
      redirect_to project_path(award.project)
    else
      fail_and_redirect(result.message)
    end
  end

  def confirm
    if current_account
      award = Award.find_by confirm_token: params[:token]
      if award
        award.confirm!(current_account)
        redirect_to project_path(award.project)
      else
        flash[:error] = 'Invalid award token!'
        redirect_to root_path
      end
    else
      session[:award_token] = params[:token]
      redirect_to new_session_path
    end
  end

  def update_transaction_address
    @award = @project.awards.find params[:id]
    @award.update! ethereum_transaction_address: params[:tx]
    @award = @award.decorate
    render layout: false
  end

  def fail_and_redirect(message)
    flash[:error] = "Failed sending award - #{message}"
    redirect_back fallback_location: root_path
  end

  private

  def award_params
    params.require(:award).permit(:uid, :quantity, :description)
  end
end
