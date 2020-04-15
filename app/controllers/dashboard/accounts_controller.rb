class Dashboard::AccountsController < ApplicationController
  before_action :assign_project
  before_action :set_accounts, only: [:index]
  before_action :create_token_records, only: [:index]
  before_action :set_account, only: [:update]
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: [:index]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :accounts?
  end

  def update
    authorize @project, :edit_accounts?

    if @account.update(
      account_params.merge(
        lockup_until: account_params[:lockup_until] ? Date.parse(account_params[:lockup_until])&.in_time_zone : nil
      )
    )
      Blockchain::ComakerySecurityToken::AccountSyncJob.perform_later(@account)
      redirect_to project_dashboard_accounts_path(@project, page: @page), notice: 'Account updated'
    else
      redirect_to project_dashboard_accounts_path(@project, page: @page), flash: { error: @account.errors.full_messages.join(', ') }
    end
  end

  private

    def set_accounts
      @page = (params[:page] || 1).to_i
      @q = @project.interested.includes(:verifications, :awards, :latest_verification, account_token_records: [:reg_group]).ransack(params[:q])
      @accounts_all = @q.result
      @accounts = @accounts_all.page(@page).per(10)
      redirect_to '/404.html' if (@page > 1) && @accounts.out_of_range?
    end

    def create_token_records
      if @project.token&.coin_type_comakery?
        @project.interested.each { |a| a.account_token_records.find_or_create_by!(token: @project.token) }
      end
    end

    def set_account
      @account = @project.token&.account_token_records&.find_by(id: params[:id])
    end

    def account_params
      params.fetch(:account_token_record, {}).permit(
        :max_balance,
        :lockup_until,
        :reg_group_id,
        :account_frozen
      )
    end
end
