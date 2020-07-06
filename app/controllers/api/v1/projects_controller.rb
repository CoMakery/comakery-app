class Api::V1::ProjectsController < Api::V1::ApiController
  # GET /api/v1/projects
  def index
    fresh_when projects, public: true
  end

  # GET /api/v1/projects/1
  def show
    fresh_when project, public: true
  end

  private

    def projects
      @projects ||= paginate(project_scope.includes(:token, :admins, :account, :transfer_types))
    end

    def project
      @project ||= projects.find(params[:id])
    end
end
