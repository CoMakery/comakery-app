class MissionsController < ApplicationController
  skip_before_action :require_login, only: %i[show]

  before_action :unavailable_for_whitelabel
  before_action :find_mission_by_id, only: %i[show edit update update_status destroy]
  before_action :set_form_props, only: %i[new edit]
  before_action :set_mission_props, only: %i[show]
  before_action :set_missions, only: %i[index rearrange]

  def index
    render component: 'MissionIndex', props: { csrf_token: form_authenticity_token, missions: @missions }
  end

  def new
    @mission = Mission.new
    authorize @mission

    @props[:mission] = @mission&.serialize
    render component: 'MissionForm', props: @props
  end

  def show
    authorize @mission

    @meta_title = 'CoMakery Mission'
    @meta_desc = "#{@mission.name}: #{@mission.description}"
    @meta_image = Refile.attachment_url(@mission, :image)

    render component: 'Mission', props: @props
  end

  def create
    @mission = Mission.new(mission_params)
    authorize @mission
    if @mission.save
      render json: { id: @mission.id, message: 'Successfully created.' }, status: :ok
    else
      errors = @mission.errors.as_json
      errors.each { |key, value| errors[key] = value.to_sentence }
      render json: { message: @mission.errors.full_messages.join(', '), errors: errors }, status: :unprocessable_entity
    end
  end

  def edit
    authorize @mission

    @props[:form_url] = mission_path(@mission)
    @props[:form_action] = 'PATCH'
    render component: 'MissionForm', props: @props
  end

  def update
    authorize @mission
    if @mission.update(mission_params)
      render json: { message: 'Successfully updated.' }, status: :ok
    else
      errors = @mission.errors.as_json
      errors.each { |key, value| errors[key] = value.to_sentence }
      render json: { message: @mission.errors.full_messages.join(', '), errors: errors }, status: :unprocessable_entity
    end
  end

  def rearrange
    authorize Mission.new
    # rearrange feature
    mission_ids = params[:mission_ids]
    display_orders = params[:display_orders]
    direction = params[:direction].to_i
    length = mission_ids.length

    (0..length - 1).each do |index|
      mission = Mission.find(mission_ids[index])
      mission.display_order = display_orders[(index + direction + length) % length]
      mission.save
    end

    render json: { missions: @missions, message: 'Successfully updated.' }, status: :ok
  end

  private

  def mission_params
    params.require(:mission).permit(
      :name,
      :subtitle,
      :description,
      :logo,
      :image,
      :status,
      :whitelabel,
      :whitelabel_domain,
      :whitelabel_logo,
      :whitelabel_logo_dark,
      :whitelabel_favicon,
      :whitelabel_contact_email,
      :whitelabel_api_public_key
    )
  end

  def find_mission_by_id
    @mission = Mission.find(params[:id])
  end

  def contributor_props(account, project)
    a = account.decorate.serializable_hash(
      only: %i[id nickname first_name last_name linkedin_url github_url dribble_url behance_url],
      include: :specialty,
      methods: :image_url
    )

    a['specialty'] ||= {}

    if project.account == account || project.admins.include?(account)
      a['specialty']['name'] = 'Team Leader'
    elsif !project.contributors_distinct.include?(account)
      a['specialty']['name'] = 'Interested'
    end

    a
  end

  def project_props(project)
    project.as_json(only: %i[id title]).merge(
      # description: Comakery::Markdown.to_html(project.description),
      description: project.description_html_truncated(500),
      image_url: project.panoramic_image.present? ? Refile.attachment_url(project, :panoramic_image) : nil,
      square_url: project.square_image.present? ? Refile.attachment_url(project, :square_image, :fill, 800, 800) : nil,
      default_image_url: helpers.image_url('defaul_project.jpg'),
      team_size: project.team_size,
      team: project.team_top.map { |contributor| contributor_props(contributor, project) }
    )
  end

  def project_leaders(mission)
    project_counts = mission.leaders.group(:account_id).count

    mission.leaders.distinct.limit(4).map do |account|
      account.serializable_hash.merge(
        count: project_counts[account.id],
        project_name: mission.public_projects.find_by(account_id: account.id).title,
        image_url: helpers.account_image_url(account, 240)
      )
    end
  end

  def project_tokens(mission)
    project_counts = mission.tokens.group(:token_id).count

    {
      tokens:
        mission.tokens.distinct.limit(4).map do |token|
          token.serializable_hash.merge(
            count: project_counts[token.id],
            project_name: mission.public_projects.find_by(token_id: token.id).title,
            logo_url: token.logo_image.present? ? Refile.attachment_url(token, :logo_image, :fill, 30, 30) : nil,
            contract_url: token.decorate.ethereum_contract_explorer_url
          )
        end,
      token_count: mission.tokens.distinct.size
    }
  end

  def set_mission_props
    projects = @mission.public_projects.order('interests_count DESC').includes(:token, :interested, :award_types, :ready_award_types, :account, admins: [:specialty], contributors_distinct: [:specialty])

    @props = {
      mission: @mission&.serializable_hash&.merge(mission_images)&.merge({ stats: @mission.stats }),
      leaders: project_leaders(@mission),
      tokens: project_tokens(@mission),
      new_project_url: new_project_path(mission_id: @mission.id),
      csrf_token: form_authenticity_token,
      projects: projects.map do |project|
        {
          project_url: project_url(project),
          editable: current_account&.id == project.account_id,
          interested: project.interested.include?(current_account),
          project_data: project_props(project.decorate),
          token_data: project.token&.as_json(only: %i[name])&.merge(
            logo_url: project.token&.logo_image.present? ? Refile.attachment_url(project.token, :logo_image, :fill, 30, 30) : nil
          ),
          stats: project.stats
        }
      end
    }
  end

  def set_form_props
    @props = {
      mission: @mission&.serializable_hash&.merge(mission_images),
      form_url: missions_path,
      form_action: 'POST',
      url_on_success: missions_path,
      csrf_token: form_authenticity_token
    }
  end

  def mission_images
    {
      logo_url: Refile.attachment_url(@mission, :logo, :fill, 800, 800),
      image_url: Refile.attachment_url(@mission, :image, :fill, 1200, 800),
      whitelabel_logo_url: @mission&.whitelabel_logo&.present? ? Refile.attachment_url(@mission, :whitelabel_logo, :fill, 1000, 200) : nil,
      whitelabel_logo_dark_url: @mission&.whitelabel_logo_dark&.present? ? Refile.attachment_url(@mission, :whitelabel_logo_dark, :fill, 1000, 200) : nil,
      whitelabel_favicon_url: @mission&.whitelabel_favicon&.present? ? Refile.attachment_url(@mission, :whitelabel_favicon, :fill, 64, 64) : nil
    }
  end

  def set_missions
    @missions = policy_scope(Mission).includes(:public_projects, :unarchived_projects).map do |m|
      m.serialize.merge(
        projects: m.public_projects.as_json(only: %i[id title status])
      )
    end
  end
end
