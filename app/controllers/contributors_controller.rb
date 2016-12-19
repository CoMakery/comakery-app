class ContributorsController < ApplicationController
  before_filter :assign_project, only: :index
  skip_before_filter :require_login, only: :index

  def index
    @award_data = GetAwardData.call(authentication: current_account&.slack_auth, project: @project).award_data
  end

  private
  def assign_project
    @project = policy_scope(Project).find(params[:project_id]).decorate
  end
end