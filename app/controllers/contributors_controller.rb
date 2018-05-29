class ContributorsController < ApplicationController
  before_action :assign_project
  skip_before_action :require_login, only: :index

  def index
    @award_data = GetContributorData.call(account: current_account, project: @project).award_data
  end
end
