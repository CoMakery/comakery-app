class AwardsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :update_transaction_address

  before_action :assign_project, only: %i[create index update_transaction_address]
  skip_before_action :require_login, only: %i[index confirm]
  skip_after_action :verify_authorized

  def index
    authorize @project, :show_contributions?
    @awards = @project.awards
    @awards = @awards.where(account_id: current_account.id) if current_account && params[:mine] == 'true'
    @awards = @awards.order(created_at: :desc).page(params[:page]).decorate
  end

  def create
    quantity = params[:award][:quantity]&.delete(',')
    result = AwardSlackUser.call(project: @project, issuer: current_account, award_type_id: params[:award][:award_type_id], channel_id: params[:award][:channel_id], uid: params[:award][:uid], quantity: quantity, description: params[:award][:description])
    if result.success?
      award = result.award
      authorize award
      if award.save
        award.send_award_notifications
        award.send_confirm_email
        generate_message(award)
        redirect_to project_path(award.project)
      else
        render_back(award.errors.full_messages.first)
      end
    else
      render_back(result.message)
    end
  rescue Pundit::NotAuthorizedError
    fail_and_redirect('Not authorized')
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
    skip_authorization
    flash[:error] = "Failed sending award - #{message}"
    redirect_back fallback_location: root_path
  end

  private

  def generate_message(award)
    flash[:notice] = if !award.self_issued? && award.decorate.recipient_address.blank?
      "The award recipient hasn't entered a blockchain address for us to send the award to. When the recipient enters their blockchain address you will be able to approve the token transfer on the awards page."
    else
      "Successfully sent award to #{award.decorate.recipient_display_name}"
    end
  end

  def award_params
    params.require(:award).permit(:uid, :quantity, :description, :channel_id, :award_type_id)
  end

  def render_back(msg)
    authorize @project
    @award = Award.new(award_params)
    @award.email = params[:award][:uid] unless @award.channel_id
    awardable_types_result = GetAwardableTypes.call(account: current_account, project: @project)
    @awardable_types = awardable_types_result.awardable_types
    @can_award = awardable_types_result.can_award
    flash[:error] = "Failed sending award - #{msg}"
    render template: 'projects/show'
  end
end
