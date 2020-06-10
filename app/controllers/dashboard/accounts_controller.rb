class Dashboard::AccountsController < ApplicationController
  before_action :assign_project
  before_action :set_accounts, only: [:index]
  before_action :create_token_records, only: [:index]
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: [:index]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :accounts?
  end

  private

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

    def create_token_records
      if @project.token&.coin_type_comakery?
        @project.interested.each { |a| a.account_token_records.find_or_create_by!(token: @project.token) }
      end
    end
end
