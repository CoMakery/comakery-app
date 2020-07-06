class Dashboard::TransfersController < ApplicationController
  before_action :assign_project
  before_action :set_award_type, only: [:create]
  before_action :set_transfers, only: [:index]
  before_action :set_transfer, only: [:show]
  skip_before_action :require_login, only: %i[index show]
  skip_after_action :verify_policy_scoped, only: %i[index show]

  fragment_cache_key do
    "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}"
  end

  def index
    authorize @project, :transfers?
  end

  def show
    authorize @project, :transfers?
  end

  def create
    authorize @project, :create_transfer?

    @transfer = @award_type.awards.new(transfer_params)
    @transfer.name = @transfer.transfer_type.name.titlecase
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
      @transfers_all = @q.result.includes(:issuer, :project, :award_type, :token, :blockchain_transactions, :latest_blockchain_transaction, account: %i[verifications latest_verification])
      @transfers_all.size
      @transfers = @transfers_all.page(@page).per(10)
      redirect_to '/404.html' if (@page > 1) && @transfers.out_of_range?
    rescue ActiveRecord::StatementInvalid
      head 404
    end

    def set_transfer
      @transfer = @project.awards.completed.find(params[:id])
    end

    def set_award_type
      @award_type = @project.default_award_type
    end

    def transfer_params
      params.fetch(:award, {}).permit(
        :amount,
        :quantity,
        :why,
        :description,
        :requirements,
        :transfer_type_id
      )
    end
end
