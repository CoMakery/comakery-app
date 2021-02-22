class Dashboard::AccountsController < ApplicationController
  before_action :assign_project
  before_action :normalize_account_token_records_lockup_until_lt, only: [:index]
  before_action :set_accounts, only: [:index]
  before_action :authorize_project, only: :create
  skip_before_action :require_login, only: %i[index show]
  skip_after_action :verify_policy_scoped, only: %i[index create]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :accounts?
  end

  def create
    authorize @project, :edit_accounts?

    account_token_record = @project.token.account_token_records.new(account_token_record_params)
    account_token_record.account_id = params.dig(:account_token_record, :account_id)
    account_token_record.lockup_until = Time.zone.parse(account_token_record_params[:lockup_until])

    if account_token_record.save
      if account_token_record.token.blockchain.supported_by_ore_id?
        redirect_to sign_ore_id_new_path(account_token_record_id: account_token_record.id)
      else
        @account_token_record = account_token_record

        render 'api/v1/account_token_records/show.json', status: :created
      end
    else
      @errors = account_token_record.errors

      render 'api/v1/error.json', status: :bad_request
    end
  end

  def show
    authorize @project, :accounts?

    account = @project.interested.find(params[:id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("project_#{@project.id}_account_#{account.id}", partial: 'dashboard/accounts/account',
                                                                                                  locals: { account: account })
      end

      format.html { redirect_to root_path }
    end
  end

  def refresh_from_blockchain
    authorize @project, :accounts?

    if @project.token.account_token_records.fresh?
      notice = 'Accounts were already synced'
    else
      AlgorandSecurityToken::AccountTokenRecordsSyncJob.perform_now(@project.token) if @project.token.token_type.is_a?(TokenType::AlgorandSecurityToken)

      notice = 'Accounts were synced from the blockchain'
    end

    redirect_to project_dashboard_accounts_path(@project), notice: notice
  end

  private

    def normalize_account_token_records_lockup_until_lt
      t = params.fetch(:q, {}).fetch(:account_token_records_lockup_until_lt, nil)
      params[:q][:account_token_records_lockup_until_lt] = Time.zone.parse(t)&.to_i if t
    end

    def set_accounts
      @page = (params[:page] || 1).to_i
      @q = @project.interested.includes(
        :verifications,
        :awards,
        :latest_verification,
        account_token_records: [:reg_group]
      ).where.not(account_token_records: { id: nil }).ransack(params[:q])

      @accounts_all = @q.result
      @accounts_all.size
      @accounts = @accounts_all.page(@page).per(10)
      redirect_to '/404.html' if (@page > 1) && @accounts.out_of_range?
    rescue ActiveRecord::StatementInvalid
      head 404
    end

    def authorize_project
      authorize @project, :edit?
    end

    def account_token_record_params
      params.fetch(:account_token_record, {}).permit(
        :max_balance,
        :lockup_until,
        :reg_group_id,
        :account_frozen
      )
    end
end
