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
    name = @transfer.transfer_type.name

    @transfer.name = name.titlecase
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

    def query
      @transfers_unfiltered =
        @project
        .awards
        .completed_or_cancelled
        .includes(issuer: [image_attachment: :blob], account: [image_attachment: :blob])

      @transfers_unfiltered = @transfers_unfiltered.not_cancelled unless params.fetch(:q, {}).fetch(:filter, nil) == 'cancelled'
      @transfers_unfiltered = @transfers_unfiltered.not_burned unless transfer_type_name == 'burn'

      @q = @transfers_unfiltered.ransack(params[:q])
    end

    def set_transfers
      @page = (params[:page] || 1).to_i
      @transfers_all = query.result(distinct: true)
                            .reorder('')
                            .includes(:issuer, :project, :award_type, :token, :blockchain_transactions, :latest_blockchain_transaction, account: %i[verifications latest_verification wallets ore_id_account])

      @transfers_all.size
      ordered_transfers = @transfers_all.ransack_reorder(params.dig(:q, :s))
      @transfers = ordered_transfers.page(@page).per(10)

      if (@page > 1) && @transfers.out_of_range?
        flash.notice = "Displaying first page of filtered results. Not enough results to display page #{@page}."
        @page = 1
        @transfers = ordered_transfers.page(@page).per(10)
      end
    rescue ActiveRecord::StatementInvalid
      head 404
    end

    def set_transfer
      @transfer = @project.awards.completed.find(params[:id])
    end

    def set_award_type
      @award_type = @project.default_award_type
    end

    def transfer_type_name
      @transfer_type_name ||= TransferType.find_by(id: params.dig(:q, :transfer_type_id_eq))&.name
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
