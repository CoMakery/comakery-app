class MissionsController < ApplicationController
  layout 'react'
  skip_before_action :require_login, only: %i[show]

  before_action :find_mission_by_id, only: %i[show edit update update_status destroy]
  before_action :set_generic_props, only: %i[new show edit]
  before_action :set_missions_prop, only: %i[index]
  before_action :set_detailed_props, only: %i[show]

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

    set_missions_prop
    render json: { missions: @missions, message: 'Successfully updated.' }, status: :ok
  end

  private

  def mission_params
    params.require(:mission).permit(:name, :subtitle, :description, :logo, :image, :status)
  end

  def find_mission_by_id
    @mission = Mission.find(params[:id])
  end

  def project_leaders(mission)
    leaders = mission.projects.public_listed.select('accounts.id').joins('left join accounts on projects.account_id=accounts.id')
    project_counts = leaders.group(:account_id).count

    Account.where(id: leaders).limit(4).select('id, first_name, last_name, image_id').map do |account|
      account.as_json.merge(
        count: project_counts[account.id],
        project_name: mission.projects.public_listed.find_by(account_id: account.id).title,
        image_url: account.image.present? ? Refile.attachment_url(account, :image, :fill, 240, 240) : nil
      )
    end
  end

  def project_tokens(mission)
    tokens = mission.projects.public_listed.select('tokens.id').joins('left join tokens on projects.token_id=tokens.id')
    project_counts = tokens.group(:token_id).count

    {
      tokens:
        Token.where(id: tokens).limit(4).select('id, name, symbol, coin_type, logo_image_id, ethereum_contract_address, ethereum_network, blockchain_network, contract_address').map do |token|
          token.as_json.merge(
            count: project_counts[token.id],
            project_name: mission.projects.public_listed.find_by(token_id: token.id).title,
            logo_url: token.logo_image.present? ? Refile.attachment_url(token, :logo_image, :fill, 30, 30) : nil,
            contract_url: token.decorate.ethereum_contract_explorer_url
          )
        end,
      token_count: tokens.size
    }
  end

  def set_detailed_props
    projects = @mission.projects.public_listed

    @props = {
      mission: @mission&.serializable_hash&.merge(
        {
          logo_url: @mission&.logo&.present? ? Refile.attachment_url(@mission, :logo, :fill, 800, 800) : nil,
          image_url: @mission&.image&.present? ? Refile.attachment_url(@mission, :image, :fill, 1200, 800) : nil
        }
      ),
      leaders: project_leaders(@mission),
      tokens: project_tokens(@mission),
      new_project_url: new_project_path(mission_id: @mission.id),
      csrf_token: form_authenticity_token,
      stats: {
        projects: projects.size,
        batches: projects.select('award_types.id').joins(:award_types).size,
        tasks: projects.select('awards.id').joins(:awards).size,
        interests: Interest.where(project_id: projects).select(:account_id).distinct.size
      },
      projects: projects.map do |project|
        {
          editable: current_account&.id == project.account_id,
          interested: Interest.exists?(account_id: current_account&.id, project_id: project.id),
          project_data: project_props(project.decorate),
          token_data: project.token.as_json(only: %i[name]).merge(
            logo_url: project.token.logo_image.present? ? Refile.attachment_url(project.token, :logo_image, :fill, 30, 30) : nil
          ),
          batches: project.award_types.size,
          tasks: project.awards.size
        }
      end
    }
  end

  def set_generic_props
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

  def set_missions_prop
    @missions = policy_scope(Mission).map do |m|
      m.serialize.merge(
        projects: m.projects.public_listed.as_json(only: %i[id title status])
      )
    end
  end
end
