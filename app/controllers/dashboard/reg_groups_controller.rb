class Dashboard::RegGroupsController < ApplicationController
  before_action :assign_project
  before_action :set_reg_group, only: [:destroy]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def create
    authorize @project, :edit_reg_groups?

    @reg_group = @project.token.reg_groups.new(reg_group_params)

    if @reg_group.save
      redirect_to project_dashboard_transfer_rules_path(@project), notice: 'Group created'
    else
      redirect_to project_dashboard_transfer_rules_path(@project), flash: { error: @reg_group.errors.full_messages.join(', ') }
    end
  end

  def destroy
    authorize @project, :edit_reg_groups?

    if @reg_group.destroy
      redirect_to project_dashboard_transfer_rules_path(@project), notice: 'Group destroyed'
    else
      redirect_to project_dashboard_transfer_rules_path(@project), flash: { error: @reg_group.errors.full_messages.join(', ') }
    end
  end

  private

    def set_reg_group
      @reg_group = @project.token.reg_groups.find(params[:id])
    end

    def reg_group_params
      params.fetch(:reg_group, {}).permit(
        :name,
        :blockchain_id
      )
    end
end
