class Api::V1::ProjectRolesController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  # GET /api/v1/accounts/1/project_roles
  def index
    fresh_when project_involved_accounts, public: true
  end

  # POST /api/v1/accounts/1/project_roles
  def create
    project_role = ProjectRole.new(
      account: account,
      project: project_scope.find(params.fetch(:body, {}).fetch(:data, {}).fetch(:project_id, nil))
    )

    if project_role.save
      project_involved_accounts

      render 'index.json', status: :created
    else
      @errors = project_role.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  # DELETE /api/v1/accounts/1/project_roles/1
  def destroy
    project_involved_account.project_roles.find_by!(account: account).destroy

    project_involved_accounts

    render 'index.json', status: :ok
  end

  private

    def account
      @account ||= whitelabel_mission.managed_accounts.find_by!(managed_account_id: params[:account_id])
    end

    def project_involved_accounts
      @project_involved_accounts ||= paginate(account.projects_involved.where(mission: whitelabel_mission))
    end

    def project_involved_account
      @project_involved_account ||= account.projects_involved.where(mission: whitelabel_mission).find(params[:id])
    end
end
