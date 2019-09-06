class MissionsController < ApplicationController
  layout 'react'
  skip_before_action :require_login, only: %i[show]

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
    params.require(:mission).permit(:name, :subtitle, :description, :logo, :image, :status)
  end

  def find_mission_by_id
    @mission = Mission.find(params[:id])
  end

  def contributor_props(account)
    account.as_json(only: %i[id nickname first_name last_name]).merge(
      image_url: helpers.account_image_url(account, 68),
      specialty: account.specialty&.name
    )
  end

  def project_props(project)
    contributors_number = project.contributors_by_award_amount.size
    award_data = GetContributorData.call(project: project).award_data
    chart_data = award_data[:contributions_summary_pie_chart].map { |award| award[:net_amount] }.sort { |a, b| b <=> a }

    project.as_json(only: %i[id title description]).merge(
      image_url: project.panoramic_image.present? ? Refile.attachment_url(project, :panoramic_image) : nil,
      square_url: project.square_image.present? ? Refile.attachment_url(project, :square_image, :fill, 800, 800) : nil,
      youtube_url: project.video_id,
      default_image_url: helpers.image_url('defaul_project.jpg'),
      owner: project.account.decorate.name,
      token_percentage: project.percent_awarded_pretty,
      maximum_tokens: project.maximum_tokens_pretty,
      awarded_tokens: project.total_awarded_pretty,
      team_leader: contributor_props(project.account),
      contributors_number: contributors_number,
      contributors: project.top_contributors.map { |contributor| contributor_props(contributor) },
      chart_data: chart_data
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
    projects = @mission.public_projects

    @props = {
      mission: @mission&.serializable_hash&.merge(
        {
          logo_url: @mission&.logo&.present? ? Refile.attachment_url(@mission, :logo, :fill, 800, 800) : nil,
          image_url: @mission&.image&.present? ? Refile.attachment_url(@mission, :image, :fill, 1200, 800) : nil,
          stats: @mission.stats
        }
      ),
      leaders: project_leaders(@mission),
      tokens: project_tokens(@mission),
      new_project_url: new_project_path(mission_id: @mission.id),
      csrf_token: form_authenticity_token,
      projects: projects.map do |project|
        {
          project_url: project_url(project),
          editable: current_account&.id == project.account_id,
          interested: Interest.exists?(account_id: current_account&.id, project_id: project.id),
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
      mission: @mission&.serializable_hash&.merge(
        {
          logo_url: @mission&.logo&.present? ? Refile.attachment_url(@mission, :logo, :fill, 800, 800) : nil,
          image_url: @mission&.image&.present? ? Refile.attachment_url(@mission, :image, :fill, 1200, 800) : nil
        }
      ),
      form_url: missions_path,
      form_action: 'POST',
      url_on_success: missions_path,
      csrf_token: form_authenticity_token
    }
  end

  def set_missions
    @missions = policy_scope(Mission).map do |m|
      m.serialize.merge(
        projects: m.public_projects.as_json(only: %i[id title status])
      )
    end
  end
end
