class MissionsController < ApplicationController
  layout 'react'
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

  def set_detailed_props
    projects = @mission.projects.public_listed

    @props = {
      mission: @mission&.serializable_hash&.merge(
        {
          logo_url: @mission&.logo&.present? ? Refile.attachment_url(@mission, :logo, :fill, 800, 800) : nil,
          image_url: @mission&.image&.present? ? Refile.attachment_url(@mission, :image, :fill, 1200, 800) : nil
        }
      ),
      leaders: @mission.project_leaders,
      tokens: @mission.project_tokens,
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
          editable: current_account.id == project.account_id,
          interested: Interest.exists?(account_id: current_account.id, project_id: project.id),
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
