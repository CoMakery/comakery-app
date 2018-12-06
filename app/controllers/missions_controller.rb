class MissionsController < ApplicationController
  layout 'react'
  before_action :find_mission_by_id, only: %i[edit update destroy]
  skip_after_action :verify_policy_scoped, only: %i[index]

  def index
    @missions = Mission.all.map { |mission| mission.as_json(only: %i[id name subtitle description]).merge(image_preview: Refile.attachment_url(mission, :image, :fill, 230, 230)) }
    authorize Mission.new
  end

  def new
    @mission = Mission.new
    authorize @mission
  end

  def create
    @mission = Mission.new(mission_params)
    authorize @mission
    if @mission.save
      render json: { message: 'Successfully created.' }, status: :ok
    else
      errors = @mission.errors.as_json
      errors.each { |key, value| errors[key] = value.to_sentence }
      render json: { message: @mission.errors.full_messages.join(', '), errors: errors }, status: :unprocessable_entity
    end
  end

  def edit
    authorize @mission
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

  def destroy
    authorize @mission
  end

  private

  def mission_params
    params.require(:mission).permit(:name, :subtitle, :description, :logo, :image)
  end

  def find_mission_by_id
    @mission = Mission.find(params[:id])
  end
end
