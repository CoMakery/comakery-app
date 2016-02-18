class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
    @project.reward_types.build
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
    @project = Project.includes(:reward_types).find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    @project.update(project_params)
    flash[:notice] = "Project updated"
    respond_with @project, location: project_path(@project)
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :tracker, :public, reward_types_attributes: [:id, :name, :suggested_amount])
  end
end
