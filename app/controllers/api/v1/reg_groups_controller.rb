class Api::V1::RegGroupsController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  # GET /api/v1/projects/1/reg_groups
  def index
    fresh_when reg_groups, public: true
  end

  # GET /api/v1/projects/1/reg_groups/1
  def show
    fresh_when reg_group, public: true
  end

  # POST /api/v1/projects/1/reg_groups
  def create
    reg_group = project.token.reg_groups.create(reg_group_params)

    if reg_group.save
      @reg_group = reg_group

      render 'show.json', status: 201
    else
      @errors = reg_group.errors

      render 'api/v1/error.json', status: 400
    end
  end

  # DELETE /api/v1/projects/1/reg_groups/1
  def destroy
    reg_group.destroy
    render 'index.json', status: 200
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def reg_groups
      @reg_groups ||= paginate(project.token.reg_groups)
    end

    def reg_group
      @reg_group ||= project.token.reg_groups.find(params[:id])
    end

    def reg_group_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:reg_group, {}).permit(
        :name,
        :blockchain_id
      )
    end
end
