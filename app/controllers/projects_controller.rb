class ProjectsController < ApplicationController
  skip_before_action :require_login, except: %i[new edit create update update_status landing]
  skip_after_action :verify_authorized, only: %i[teams landing]
  before_action :assign_current_account

  before_action :set_project, only: %i[edit update]
  before_action :set_tokens, only: %i[new show edit]
  before_action :set_missions, only: %i[new show edit]
  before_action :set_visibilities, only: %i[new show edit]
  before_action :set_generic_props, only: %i[new show edit]

  layout 'react', only: %i[new edit]

  def landing
    if current_account
      check_account_info
      @my_projects = current_account.projects.unarchived.with_last_activity_at.limit(6).decorate
      @archived_projects = current_account.projects.archived.with_last_activity_at.limit(6).decorate
      @team_projects = current_account.other_member_projects.unarchived.with_last_activity_at.limit(6).decorate
    end
    @my_project_contributors = TopContributors.call(projects: @my_projects).contributors
    @team_project_contributors = TopContributors.call(projects: @team_projects).contributors
    @archived_project_contributors = TopContributors.call(projects: @archived_projects).contributors
  end

  def index
    @projects = policy_scope(Project)

    if params[:query].present?
      @projects = @projects.where(['projects.title ilike :query OR projects.description ilike :query', query: "%#{params[:query]}%"])
    end
    @projects = @projects.order(updated_at: :desc).includes(:account).page(params[:page]).per(9)

    @project_contributors = TopContributors.call(projects: @projects).contributors
  end

  def new
    assign_slack_channels

    @project = current_account.projects.build
    @project.channels.build if current_account.teams.any?
    @project.long_id ||= SecureRandom.hex(20)

    authorize @project

    @props[:project] = @project.serializable_hash.merge(
      url: "https://www.comakery.com/p/#{@project.long_id}"
    )
    render component: 'ProjectForm', props: @props
  end

  def create
    @project = current_account.projects.build project_params
    @project.maximum_royalties_per_month = 50_000
    @project.public = false
    @project.long_id ||= SecureRandom.hex(20)

    unless params['project']['award_types_attributes']
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
    end

    authorize @project

    if @project.save
      render json: { id: @project.id }, status: :ok
    else
      errors  = @project.errors.messages.map { |k, v| ["project[#{k}]", v.to_sentence] }.to_h
      message = @project.errors.full_messages.join(', ')
      render json: { message: message, errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    @project = Project.listed.find(params[:id])&.decorate
    authorize @project
    set_award
  end

  def unlisted
    @project = Project.find_by(long_id: params[:long_id])&.decorate
    authorize @project
    if @project&.access_unlisted?(current_account)
      set_award
      render :show
    elsif @project&.can_be_access?(current_account)
      redirect_to project_path(@project)
    end
  end

  def edit
    @project.channels.build if current_account.teams.any?
    @project.long_id ||= SecureRandom.hex(20)
    authorize @project
    assign_slack_channels

    @props[:form_action] = 'PATCH'
    @props[:form_url]    = project_path(@project)

    render component: 'ProjectForm', props: @props
  end

  def update
    @project = current_account.projects.includes(:award_types, :channels).find(params[:id])
    @project.long_id ||= params[:long_id] || SecureRandom.hex(20)
    authorize @project

    if @project.update project_params
      render json: { message: 'Project updated' }, status: :ok
    else
      errors  = @project.errors.messages.map { |k, v| [k, v.to_sentence] }.to_s
      message = @project.errors.full_messages.join(', ')
      render json: { message: message, errors: errors }, status: :unprocessable_entity
    end
  end

  def update_status
    @project = Project.find(params[:project_id])
    authorize @project

    begin
      @project.update(status: params[:status])
      render json: { message: 'Successfully updated.' }, status: :ok
    rescue ArgumentError
      render json: { message: 'Invalid Status' }, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:id]).decorate
  end

  def set_tokens
    @tokens = Token.all.map { |t| [t.name, t.id] }.to_h
  end

  def set_missions
    @missions = Mission.all.map { |m| [m.name, m.id] }.to_h
  end

  def set_visibilities
    @visibilities = Project.visibilities.keys
  end

  def set_generic_props
    @props = {
      project: @project&.serializable_hash&.merge(
        {
          square_image_url: @project&.square_image&.present? ? Refile.attachment_url(@project, :square_image, :fill, 800, 800) : nil,
          panoramic_image_url: @project&.panoramic_image&.present? ? Refile.attachment_url(@project, :panoramic_image, :fill, 1500, 300) : nil,
          mission_id: @project&.mission&.id,
          token_id: @project&.token&.id,
          url: "https://www.comakery.com/p/#{@project.long_id}"
        }
      ),
      tokens: @tokens,
      missions: @missions,
      visibilities: @visibilities,
      form_url: projects_path,
      form_action: 'POST',
      url_on_success: projects_path,
      csrf_token: form_authenticity_token
    }
  end

  def project_params
    result = params.require(:project).permit(
      :revenue_sharing_end_date,
      :contributor_agreement_url,
      :description,
      :square_image,
      :panoramic_image,
      :maximum_tokens,
      :token_id,
      :mission_id,
      :long_id,
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
      :visibility,
      :status,
      award_types_attributes: %i[
        _destroy
        amount
        community_awardable
        id
        name
        description
        disabled
      ],
      channels_attributes: %i[id team_id channel_id _destroy]
    )
    result[:revenue_sharing_end_date] = DateTime.strptime(result[:revenue_sharing_end_date], '%m/%d/%Y') if result[:revenue_sharing_end_date].present?
    result
  end

  def assign_slack_channels
    @providers = current_account.teams.map(&:provider).uniq
    @provider_data = {}
    @providers.each do |provider|
      teams = current_account.teams.where(provider: provider)
      team_data = []
      teams.each do |_team|
        team_data
      end
      @provider_data[provider] = teams
    end
    # result = GetSlackChannels.call(current_account: current_account)
    # @slack_channels = result.channels
  end

  def assign_current_account
    @current_account_deco = current_account&.decorate
  end

  def set_award
    last_award = @project.awards.last
    @award = Award.new channel: last_award&.channel, award_type: last_award&.award_type
    awardable_types_result = GetAwardableTypes.call(account: current_account, project: @project)
    @awardable_types = awardable_types_result.awardable_types
    @can_award = awardable_types_result.can_award
  end

  def project_detail_path
    @project.unlisted? ? unlisted_project_path(@project.long_id) : project_path(@project)
  end
end
