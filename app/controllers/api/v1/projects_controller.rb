class Api::V1::ProjectsController < Api::V1::ApiController
  # GET /api/v1/projects
  def index
    fresh_when projects
  end

  # GET /api/v1/projects/1
  def show
    fresh_when project
  end

  private

    def projects
      @projects ||= project_scope.includes(:token)
    end

    def project
      @project ||= projects.find(params[:id])
    end
end
