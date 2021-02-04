class Dashboard::AccountsController < ApplicationController
  before_action :assign_project
  before_action :normalize_account_token_records_lockup_until_lt, only: [:index]
  before_action :set_accounts, only: [:index]
  before_action :create_token_records, only: [:index]
  before_action :authorize_project, only: :create
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: %i[index create]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :accounts?
  end

  def create
    account_token_record = @project.token.account_token_records.new(account_token_record_params)
    account_id = params.dig(:body, :data, :account_token_record, :account_id)
    account_token_record.account = Account.find(account_id)

    if account_token_record.save
      @project.safe_add_interested(account_token_record.account)
      @account_token_record = account_token_record
      render 'api/v1/account_token_records/show.json', status: :created
    else
      @errors = account_token_record.errors
      render 'api/v1/error.json', status: :bad_request
    end
  end

  private

    def normalize_account_token_records_lockup_until_lt
      t = params.fetch(:q, {}).fetch(:account_token_records_lockup_until_lt, nil)
      params[:q][:account_token_records_lockup_until_lt] = Time.zone.parse(t)&.to_i if t
    end

    def set_accounts
      @page = (params[:page] || 1).to_i
      @q = @project.interested.includes(:verifications, :awards, :latest_verification, account_token_records: [:reg_group]).ransack(params[:q])
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
      params
        .fetch(:body, {})
        .fetch(:data, {})
        .fetch(:account_token_record, {})
        .permit(:max_balance, :lockup_until, :reg_group_id, :account_frozen)
    end

    # TODO: Extract creation of account_token_records to model or service
    def create_token_records
      @project.interested.each { |a| a.account_token_records.find_or_create_by!(token: @project.token) } if @project.token&._token_type_comakery_security_token?
    end
end
