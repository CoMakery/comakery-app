class ProjectsController < ApplicationController
  def new
    @project = Project.new
  end

  def create
    project = Project.create!(project_params)
    flash[:notice] = "Project created"
    redirect_to project_path(project)
  end

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
    params.require(:project).permit(:title, :description, :repo)
  end
end
