class Api::V1::ProjectsController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

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
      @projects ||=
        paginate(
          project_scope
            .with_all_attached_images
            .includes(:admins, :account, :transfer_types, token: [logo_image_attachment: :blob])
        )
    end

    def project
      @project ||= projects.find(params[:id])
    end
end
