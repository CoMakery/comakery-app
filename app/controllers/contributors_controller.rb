class ContributorsController < ApplicationController
  before_action :assign_project
  skip_before_action :require_login, only: :index

  def index
    authorize @project, :show_contributions?
    @contributors = @project.contributors_by_award_amount.page(params[:page])
    @award_data = GetContributorData.call(project: @project).award_data
  end
end
