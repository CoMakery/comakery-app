class Dashboard::AccountsController < ApplicationController
  before_action :assign_project
  before_action :set_accounts, only: [:index]
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: [:index]

  fragment_cache_key do
    "#{current_user&.id}/#{project.id}"
  end

  def index
    authorize @project, :accounts?
  end

  private

    def set_accounts
      @page = (params[:page] || 1).to_i
      @q = @project.interested.ransack(params[:q])
      @accounts_all = @q.result.includes(:verifications, :awards, :latest_verification, :account_token_records)
      @accounts = @accounts_all.page(@page).per(10)
      redirect_to '/404.html' if (@page > 1) && @accounts.out_of_range?
    end
end
