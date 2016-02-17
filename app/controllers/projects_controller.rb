class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    @project.update(project_params)
    respond_with @project, location: root_path
  end

  private

  def current_account
    @current_account
  end

  def project_params
    params.require(:project).permit(:name)
  end
end
