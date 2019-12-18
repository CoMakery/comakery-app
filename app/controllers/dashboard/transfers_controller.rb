class Dashboard::TransfersController < ApplicationController
  before_action :assign_project
  before_action :set_award_type, only: [:create]
  before_action :set_transfers, only: [:index]
  skip_before_action :require_login, only: [:index]
  skip_after_action :verify_policy_scoped, only: [:index]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :transfers?
  end

  def create
    authorize @project, :create_transfer?

    @transfer = @award_type.awards.new(transfer_params)
    @transfer.name = @transfer.source.capitalize
    @transfer.account_id = params[:award][:account_id]
    @transfer.issuer = current_account
    @transfer.status = :accepted

    if @transfer.save
      redirect_to project_dashboard_transfers_path(@project), flash: { notice: 'Transfer Created' }
    else
      redirect_to project_dashboard_transfers_path(@project), flash: { error: @transfer.errors.full_messages.join(', ') }
    end
  end

  private

    def set_transfers
      @page = (params[:page] || 1).to_i
      @q = @project.awards.completed.ransack(params[:q])
      @transfers_all = @q.result.includes(:issuer, :project, :award_type, :token, account: %i[verifications latest_verification account_token_records])
      @transfers = @transfers_all.page(@page).per(10)
      redirect_to '/404.html' if (@page > 1) && @transfers.out_of_range?
    end

    def set_award_type
      @award_type = @project.default_award_type
    end

    def transfer_params
      params.fetch(:award, {}).permit(
        :amount,
        :quantity,
        :source,
        :why,
        :description,
        :requirements
      )
    end
end
