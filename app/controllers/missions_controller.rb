class MissionsController < ApplicationController
  layout 'react'
  before_action :find_mission_by_id, only: %i[edit update update_status destroy]
  before_action :set_generic_props, only: %i[new show edit]
  before_action :set_missions_prop, only: %i[index]

  def index
    render component: 'MissionIndex', props: { csrf_token: form_authenticity_token, missions: @missions }
  end

  def new
    @mission = Mission.new
    authorize @mission

    @props[:mission] = @mission&.serialize
    render component: 'MissionForm', props: @props
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

  def set_generic_props
    @props = {
      mission: @mission&.serialize,
      form_url: missions_path,
      form_action: 'POST',
      url_on_success: missions_path,
      csrf_token: form_authenticity_token
    }
  end

  def set_missions_prop
    @missions = policy_scope(Mission).map do |m|
      m.serialize.merge(
        projects: m.projects.as_json(only: %i[id title status])
      )
    end
  end
end
