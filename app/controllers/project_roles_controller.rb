class ProjectRolesController < ApplicationController
  before_action :authorize_project
  skip_before_action :verify_authenticity_token

  def create
    project_role = current_account.project_roles.new(project: project)

    if project_role.save
      head :created
    else
      render json: { errors: project_role.errors.full_messages }, status: :unprocessable_entity
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
