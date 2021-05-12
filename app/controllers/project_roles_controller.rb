class ProjectRolesController < ApplicationController
  before_action :authorize_project
  skip_before_action :verify_authenticity_token

  def create
    project_role = current_account.project_roles.new(project: project)

    if project_role.save
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    current_account.project_roles.where(project: project).destroy_all

    head :ok
  end

  private

    def project
      @project ||= @project_scope.find(params[:project_id])
    end

    def authorize_project
      authorize project, :show?
    end
end
