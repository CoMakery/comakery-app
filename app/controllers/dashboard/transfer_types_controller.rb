class Dashboard::TransferTypesController < ApplicationController
  before_action :assign_project
  before_action :set_transfer_type, only: %i[update destroy]
  skip_after_action :verify_policy_scoped, only: %i[index]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :transfer_types?
    @transfer_types = @project.transfer_types
  end

  def create
    authorize @project, :transfer_types?

    @transfer_type = @project.transfer_types.new(transfer_type_params)

    if @transfer_type.save
      redirect_to project_dashboard_transfer_types_path(@project), notice: 'Transfer Type created'
    else
      redirect_to project_dashboard_transfer_types_path(@project), flash: { error: @transfer_type.errors.full_messages.join(', ') }
    end
  end

  def update
    authorize @project, :transfer_types?

    if @transfer_type.update(transfer_type_params)
      redirect_to project_dashboard_transfer_types_path(@project), notice: 'Transfer Type updated'
    else
      redirect_to project_dashboard_transfer_types_path(@project), flash: { error: @transfer_type.errors.full_messages.join(', ') }
    end
  end

  def destroy
    authorize @project, :transfer_types?

    if @transfer_type.destroy
      redirect_to project_dashboard_transfer_types_path(@project), notice: 'Transfer Type destroyed'
    else
      redirect_to project_dashboard_transfer_types_path(@project), flash: { error: @transfer_type.errors.full_messages.join(', ') }
    end
  end

  private

    def set_transfer_type
      @transfer_type = @project.transfer_types.find(params[:id])
    end

    def transfer_type_params
      params.fetch(:transfer_type, {}).permit(
        :name
      )
    end
end
