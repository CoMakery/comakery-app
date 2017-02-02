class AwardsController < ApplicationController
  before_filter :assign_project, only: [:create, :index]
  skip_before_filter :require_login, only: :index

  def index
    authorize(@project)
    @awards = @project.awards.decorate
    @award_data = GetAwardData.call(authentication: current_account&.slack_auth, project: @project).award_data
  end

  def create
    result = AwardSlackUser.call(project: @project,
                                 slack_user_id: params[:award][:slack_user_id],
                                 issuer: current_account,
                                 award_params: award_params.except(:slack_user_id))
    if result.success?
      award = result.award
      authorize award
      award.save!
      CreateEthereumAwards.call(award: award)

      current_account.send_award_notifications(award: award)

      flash[:notice] = "Successfully sent award to #{award.recipient_display_name}"
      redirect_to project_path(award.project)
    else
      fail_and_redirect(result.message)
    end

  rescue Pundit::NotAuthorizedError
    fail_and_redirect("Not authorized")
  end

  def fail_and_redirect(message)
    skip_authorization
    flash[:error] = "Failed sending award - #{message}"
    redirect_to(:back)
  end

  private

  def award_params
    params.require(:award).permit(:slack_user_id, :award_type_id, :quantity, :description)
  end

  def assign_project
    @project = policy_scope(Project).find(params[:project_id]).decorate
  end
end
