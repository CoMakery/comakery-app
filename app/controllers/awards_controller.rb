class AwardsController < ApplicationController
  before_filter :assign_project, only: [:create, :index]
  skip_before_filter :require_login, only: :index

  def index
    authorize(@project)
    @awards = @project.awards
  end

  def create
    result = AwardSlackUser.call(project: @project,
                                 slack_user_id: params[:award][:slack_user_id],
                                 issuer: current_account,
                                 award_params: award_params.except(:slack_user_id))
    unless result.success?
      fail_and_redirect(result.message)
      return
    end

    award = result.award
    authorize award
    unless award.save
      fail_and_redirect(award.errors.full_messages.join(", "))
      return
    end

    flash[:notice] = "Successfully sent award to #{award.recipient_slack_user_name}"
    current_account.send_award_notifications(award: award)
    redirect_to project_path(award.award_type.project)
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
    params.require(:award).permit(:slack_user_id, :award_type_id, :description)
  end

  def assign_project
    @project = policy_scope(Project).find(params[:project_id])
  end
end
