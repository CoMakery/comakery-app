class Dashboard::AccessesController < ApplicationController
  before_action :assign_project
  skip_after_action :verify_policy_scoped, only: [:index]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :accesses?

    @admins = @project.project_admins
  end

  def regenerate_api_key
    authorize @project

    @project.regenerate_api_key

    redirect_to project_dashboard_accesses_path(@project), notice: 'API key has been regenerated'
  end
end
