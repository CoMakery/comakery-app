class ContributorsController < ApplicationController
  before_action :assign_project
  skip_before_action :require_login, only: :index

  def index
    @award_data = GetAwardData.call(authentication: current_account&.slack_auth, project: @project).award_data
  end

  private

  def assign_project
    project = Project.find(params[:project_id])
    @project = project.decorate if project.can_be_access?(current_account)
    redirect_to root_path unless @project
  end
end
