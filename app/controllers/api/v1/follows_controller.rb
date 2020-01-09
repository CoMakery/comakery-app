class Api::V1::FollowsController < Api::V1::ApiController
  # GET /api/v1/accounts/1/follows
  def index
    fresh_when follows, public: true
  end

  # POST /api/v1/accounts/1/follows
  def create
    interest = Interest.create(
      account: account,
      specialty: account.specialty,
      project: project_scope.find(params[:project_id])
    )

    if interest.save
      redirect_to api_v1_account_follows_path(account)
    else
      @errors = interest.errors

      render 'api/v1/error.json', status: 400
    end
  end

  # DELETE /api/v1/accounts/1/follows/1
  def destroy
    follow.interests.find_by!(account: account).destroy

    redirect_to api_v1_account_follows_path(account)
  end

  private

    def account
      @account ||= @whitabel_mission.managed_accounts.find_by!(managed_account_id: params[:id])
    end

    def follows
      @follows ||= paginate(account.projects_interested.where(mission: whitelabel_mission))
    end

    def follow
      @follow ||= account.projects_interested.where(mission: whitelabel_mission).find(params[:id])
    end
end
