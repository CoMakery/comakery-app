class ContributorsController < ApplicationController
  before_action :assign_project
  skip_before_action :require_login, only: :index

  def index
    @award_data = GetAwardData.call(authentication: current_account&.slack_auth, project: @project).award_data
  end
end
