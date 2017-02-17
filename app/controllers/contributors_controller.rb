class ContributorsController < ApplicationController
  before_filter :assign_project
  skip_before_filter :require_login, only: :index

  def index
    authorize @project, :show_contributions?
    @award_data = GetAwardData.call(authentication: current_account&.slack_auth, project: @project).award_data
  end

  private
  def assign_project
    @project = policy_scope(Project).find(params[:project_id]).decorate
  end
end