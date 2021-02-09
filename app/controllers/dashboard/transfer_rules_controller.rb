class Dashboard::TransferRulesController < ApplicationController
  before_action :assign_project
  before_action :set_reg_groups, only: [:index]
  before_action :set_transfer_rules, only: [:index]
  before_action :set_transfer_rule, only: [:destroy]
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: [:index]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :show_transfer_rules?
  end

  def destroy
    authorize @project, :edit_transfer_rules?

    if @transfer_rule.destroy
      redirect_to project_dashboard_transfer_rules_path(@project), notice: 'Transfer rule destroyed'
    else
      redirect_to project_dashboard_transfer_rules_path(@project), flash: { error: @transfer_rule.errors.full_messages.join(', ') }
    end
  end

  def pause
    authorize @project, :freeze_token?

    if @project.token.update(token_frozen: true)
      BlockchainJob::ComakerySecurityTokenJob::TokenSyncJob.perform_later(@project.token)
      redirect_to project_dashboard_transfer_rules_path(@project), notice: 'Token tranfers are frozen'
    else
      redirect_to project_dashboard_transfer_rules_path(@project), flash: { error: @project.token.errors.full_messages.join(', ') }
    end
  end

  def unpause
    authorize @project, :freeze_token?

    if @project.token.update(token_frozen: false)
      BlockchainJob::ComakerySecurityTokenJob::TokenSyncJob.perform_later(@project.token)
      redirect_to project_dashboard_transfer_rules_path(@project), notice: 'Token tranfers are unfrozen'
    else
      redirect_to project_dashboard_transfer_rules_path(@project), flash: { error: @project.token.errors.full_messages.join(', ') }
    end
  end

  def refresh_from_blockchain
    authorize @project, :refresh_transfer_rules?
    authorize @project.token, :refresh_transfer_rules_enabled?

    BlockchainJob::ComakerySecurityTokenJob::TransferRulesSyncJob.perform_now(@project.token)
    redirect_to project_dashboard_transfer_rules_path(@project), notice: 'Transfer rules were synced from the blockchain'
  end

  private

    def set_reg_groups
      @reg_groups = @project.token.reg_groups.order(:blockchain_id)
    end

    def set_transfer_rules
      @page = (params[:page] || 1).to_i
      @q = @project.token.transfer_rules.ransack(params[:q])
      @transfer_rules_all = @q.result.includes(:sending_group, :receiving_group)
      @transfer_rules = @transfer_rules_all.page(@page).per(10)
      redirect_to '/404.html' if (@page > 1) && @transfer_rules.out_of_range?
    end

    def set_transfer_rule
      @transfer_rule = @project.token.transfer_rules.find(params[:id])
    end
end