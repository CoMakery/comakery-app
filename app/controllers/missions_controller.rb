class MissionsController < ApplicationController
  layout 'react'
  skip_after_action :verify_authorized, :verify_policy_scoped, only: %i[new edit create update]
  before_action :find_mission_by_id, only: %i[edit update destroy]

  def new
    @mission = Mission.new
  end

  def create
    @mission = Mission.new(mission_params)
    if @mission.save
      render json: { message: 'Successfully created.' }, status: :ok
    else
      errors = @mission.errors.as_json
      errors.each { |key, value| errors[key] = value.to_sentence }
      render json: { message: @mission.errors.full_messages.join(', '), errors: errors }, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @mission.update(mission_params)
      render json: { message: 'Successfully updated.' }, status: :ok
    else
      errors = @mission.errors.as_json
      errors.each { |key, value| errors[key] = value.to_sentence }
      render json: { message: @mission.errors.full_messages.join(', '), errors: errors }, status: :unprocessable_entity
    end
  end

  def destroy; end

  private

  def mission_params
    params.require(:mission).permit(:name, :subtitle, :description, :logo, :image)
  end

  def find_mission_by_id
    @mission = Mission.find(params[:id])
  end
end
