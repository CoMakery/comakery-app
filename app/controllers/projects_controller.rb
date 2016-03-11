class ProjectsController < ApplicationController
  skip_before_filter :require_login

  def landing
    skip_authorization
    if current_account
      @private_projects = Project.with_last_activity_at.for_account(current_account).limit(6)
      @public_projects = Project.with_last_activity_at.not_for_account(current_account).public.limit(6)
    else
      @private_projects = []
      @public_projects = policy_scope(Project).with_last_activity_at.limit(6)
    end
    @slack_auth = current_account&.slack_auth
  end

  def index
    @projects = policy_scope(Project).with_last_activity_at
    if params[:query].present?
      @projects = @projects.where(["projects.title ilike :query OR projects.description ilike :query", query: "%#{params[:query]}%"])
    end
    @projects = @projects.to_a
  end

  def new
    assign_slack_channels

    @project = Project.new(public: true)
    authorize @project
    @project.award_types.build(name: "Thanks", amount: 10)
    @project.award_types.build(name: "Small Contribution", amount: 100)
    @project.award_types.build(name: "Contribution", amount: 1000)
  end

  def create
    # there could be multiple authentications... maybe this should be a drop down box to select which team
    # you are creating this project for if we actually allow multiple, simultaneous auths
    auth = current_account.slack_auth
    @project = Project.new(project_params.merge(owner_account: current_account,
                                                slack_team_image_34_url: auth.slack_team_image_34_url,
                                                slack_team_id: auth.slack_team_id,
                                                slack_team_name: auth.slack_team_name,
                                                slack_team_domain: auth.slack_team_domain))
    authorize @project
    if @project.save
      flash[:notice] = "Project created"
      redirect_to project_path(@project)
    else
      flash[:error] = "Project saving failed, please correct the errors below"
      assign_slack_channels
      render :new
    end
  end

  def show
    @project = Project.find(params[:id])
    authorize @project
    @award = Award.new
    @awardable_accounts = !current_account ? nil : GetAwardableAccounts.call(current_account: current_account, accounts: policy_scope(Account.includes(:authentications))).awardable_accounts
    @award_data = GetAwardData.call(current_account: current_account, project: @project).award_data
  end

  def edit
    @project = Project.includes(:award_types).find(params[:id])
    authorize @project
    assign_slack_channels
  end

  def update
    @project = Project.find(params[:id])
    @project.attributes = project_params
    authorize @project
    if @project.save
      flash[:notice] = "Project updated"
      respond_with @project, location: project_path(@project)
    else
      flash[:error] = "Project updating failed, please correct the errors below"
      assign_slack_channels
      render :edit
    end
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :image, :tracker, :public, :slack_channel,
                                    award_types_attributes: [:id, :name, :amount, :_destroy])
  end

  def assign_slack_channels
    result = GetSlackChannels.call(current_account: current_account)
    @slack_channels = result.channels
  end
end
