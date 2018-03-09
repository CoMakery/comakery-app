class ProjectsController < ApplicationController
  skip_before_action :require_login, except: :new
  skip_after_action :verify_authorized, only: [:teams]
  before_action :assign_current_account

  def landing
    skip_authorization
    if current_account
      @private_projects = current_account.team_projects.with_last_activity_at.limit(6).decorate
      @public_projects = current_account.public_projects.with_last_activity_at.limit(6).decorate
    else
      @private_projects = []
      @public_projects = policy_scope(Project).featured.with_last_activity_at.limit(6).decorate
    end
    @private_project_contributors = TopContributors.call(projects: @private_projects).contributors
    @public_project_contributors = TopContributors.call(projects: @public_projects).contributors
    @slack_auth = current_account&.slack_auth
  end

  def index
    @projects = policy_scope(Project).with_last_activity_at
    if params[:query].present?
      @projects = @projects.where(['projects.title ilike :query OR projects.description ilike :query', query: "%#{params[:query]}%"])
    end
    @projects = @projects.decorate
    @project_contributors = TopContributors.call(projects: @projects).contributors
  end

  def new
    assign_slack_channels

    @project = Project.new(public: false,
                           maximum_tokens: 1_000_000,
                           maximum_royalties_per_month: 50_000)
    @project.award_types.build(name: 'Thanks', amount: 10)
    @project.award_types.build(name: 'Software development hour', amount: 100)
    @project.award_types.build(name: 'Graphic design hour', amount: 100)
    @project.award_types.build(name: 'Product management hour', amount: 100)
    @project.award_types.build(name: 'Marketing hour', amount: 100)

    @project.award_types.build(name: 'Expert software development hour', amount: 150)
    @project.award_types.build(name: 'Expert graphic design hour', amount: 150)
    @project.award_types.build(name: 'Expert product management hour', amount: 150)
    @project.award_types.build(name: 'Expert marketing hour', amount: 150)
    @project.award_types.build(name: 'Blog post (600+ words)', amount: 150)
    @project.award_types.build(name: 'Long form article (2,000+ words)', amount: 2000)
    @project.channels.build if current_account.teams.any?
    authorize @project
  end

  def create
    # there could be multiple authentications... maybe this should be a drop down box to select which team
    # you are creating this project for if we actually allow multiple, simultaneous auths
    auth = current_account.slack_auth
    @project = Project.new(project_params.merge(account: current_account,
                                                slack_team_image_34_url: auth.slack_team_image_34_url,
                                                slack_team_image_132_url: auth.slack_team_image_132_url,
                                                slack_team_id: auth.slack_team_id,
                                                slack_team_name: auth.slack_team_name,
                                                slack_team_domain: auth.slack_team_domain))
    authorize @project
    if @project.save
      flash[:notice] = 'Project created'
      redirect_to project_path(@project)
    else
      flash[:error] = 'Project saving failed, please correct the errors below'
      assign_slack_channels
      render :new
    end
  end

  def show
    @project = Project.includes(:award_types).find(params[:id]).decorate
    authorize @project
    @award = Award.new
    @awardable_authentications = GetAwardableAuthentications.call(current_account: current_account, project: @project).awardable_authentications
    awardable_types_result = GetAwardableTypes.call(current_account: current_account, project: @project)
    @awardable_types = awardable_types_result.awardable_types
    @can_award = awardable_types_result.can_award
    @award_data = GetAwardData.call(account: current_account, project: @project).award_data
  end

  def edit
    @project = Project.includes(:award_types).find(params[:id])
    authorize @project
    assign_slack_channels
  end

  def update
    @project = Project.includes(:award_types).find(params[:id])
    @project.attributes = project_params
    authorize @project

    if @project.save
      flash[:notice] = 'Project updated'
      respond_with @project, location: project_path(@project)
    else
      flash[:error] = 'Project update failed, please correct the errors below'
      assign_slack_channels
      render :edit
    end
  end

  def teams
    @teams = current_account.teams.where(provider: params[:provider])
    elem_id = params[:elem_id]
    @elem_index = elem_id.split("_")[3] if elem_id

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  private

  def project_params
    params.require(:project).permit(
      :revenue_sharing_end_date,
      :contributor_agreement_url,
      :description,
      :ethereum_enabled,
      :image,
      :maximum_tokens,
      :public,
      :title,
      :tracker,
      :video_url,
      :payment_type,
      :exclusive_contributions,
      :legal_project_owner,
      :minimum_payment,
      :minimum_revenue,
      :require_confidentiality,
      :royalty_percentage,
      :maximum_royalties_per_month,
      :license_finalized,
      :denomination,
      award_types_attributes: %i[
        _destroy
        amount
        community_awardable
        id
        name
        description
        disabled
      ],
      channels_attributes: %i[id team_id name _destroy]
    )
  end

  def assign_slack_channels
    @providers = current_account.teams.map(&:provider).uniq
    @provider_data = {}
    @providers.each do |provider|
      teams = current_account.teams.where(provider: provider)
      team_data = []
      teams.each do |team|
        team_data
      end
      @provider_data[provider] = teams
    end
    result = GetSlackChannels.call(current_account: current_account)
    @slack_channels = result.channels
  end

  def assign_current_account
    @current_account_deco = current_account&.decorate
  end

end
