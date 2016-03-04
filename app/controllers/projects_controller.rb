class ProjectsController < ApplicationController
  skip_before_filter :require_login

  def landing
    skip_authorization
    if current_account
      @private_projects = Project.where(slack_team_id: current_account.slack_auth.slack_team_id).limit(6)
      @public_projects = Project.where(public: true).where.not(slack_team_id: current_account.slack_auth.slack_team_id).limit(6)
    else
      @private_projects = []
      @public_projects = policy_scope(Project).limit(6)
    end
  end

  def index
    @projects = policy_scope(Project)
  end

  def new
    @project = Project.new(public: true)
    authorize @project
    @project.reward_types.build(name: "Thanks", amount: 10)
    @project.reward_types.build(name: "Small Contribution", amount: 100)
    @project.reward_types.build(name: "Contribution", amount: 1000)
  end

  def create
    # there could be multiple authentications... maybe this should be a drop down box to select which team
    # you are creating this project for if we actually allow multiple, simultaneous auths
    auth = current_account.authentications.find_by(provider: "slack")
    @project = Project.new(project_params.merge(owner_account: current_account,
                                                slack_team_id: auth.slack_team_id,
                                                slack_team_name: auth.slack_team_name,
                                                slack_team_domain: auth.slack_team_domain))
    authorize @project
    if @project.save
      flash[:notice] = "Project created"
      redirect_to project_path(@project)
    else
      flash[:error] = "Project saving failed, please correct the errors below"
      render :new
    end
  end

  def show
    @project = Project.find(params[:id])
    authorize @project
    @reward = Reward.new
    if current_account
      @rewardable_accounts = GetRewardableAccounts.call(current_account: current_account, accounts: policy_scope(Account.includes(:authentications))).rewardable_accounts
    else
      @rewardable_accounts = nil
    end
  end

  def edit
    @project = Project.includes(:reward_types).find(params[:id])
    authorize @project
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
      render :edit
    end
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :image, :tracker, :public,
                                    reward_types_attributes: [:id, :name, :amount, :_destroy])
  end
end
