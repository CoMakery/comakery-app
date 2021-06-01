class Dashboard::TransfersController < ApplicationController
  before_action :assign_project
  before_action :set_award_type, only: [:create]
  before_action :set_transfers, only: %i[index]
  before_action :set_transfer, only: [:show]
  skip_before_action :require_login, only: %i[index show fetch_chart_data]
  skip_after_action :verify_policy_scoped, only: %i[index show fetch_chart_data]

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

  def fetch_chart_data
    authorize @project, :transfers?
    @page = (params[:page] || 1).to_i
    @transfers_totals = query.result(distinct: true)
    ordered_transfers = @transfers_totals.includes(:issuer, :transfer_type, :token).ransack_reorder(params.dig(:q, :s))
    @transfers = ordered_transfers.page(@page).per(10)
    @transfers = ordered_transfers.page(1).per(10) if (@page > 1) && @transfers.out_of_range?
    @project_token = @project.token
    @transfers_not_burned_total = @transfers_unfiltered.not_burned.sum(&:total_amount)
    @filter_params = params[:q]&.to_unsafe_h
    render partial: 'chart'
  end

  def prioritize
    authorize @project, :update_transfer?
    @transfer = @project.awards.find(params[:id])

    @transfer.update(prioritized_at: Time.zone.now)
    redirect_to project_dashboard_transfers_path(@project), flash: { notice: 'Transfer will be sent soon' }
  end

  private

    def query
      @transfers_unfiltered =
        @project
        .awards
        .completed_or_cancelled

      @transfers_unfiltered = @transfers_unfiltered.not_cancelled unless params.fetch(:q, {}).fetch(:filter, nil) == 'cancelled'
      @transfers_unfiltered = @transfers_unfiltered.not_burned unless transfer_type_name == 'burn'
      @q = @transfers_unfiltered.ransack(params[:q])
    end

    def set_transfers
      @transfers_chart_colors_objects = @project.transfers_chart_colors_objects
      @page = (params[:page] || 1).to_i
      @transfers_totals = query.result(distinct: true).reorder('')
      @transfers_all = @transfers_totals.includes(:project, :token, :transfer_type, :recipient_wallet,
                                                  award_type: [:project], issuer: [image_attachment: :blob],
                                                  account: [:ore_id_account, :latest_verification, image_attachment: :blob])
      @filter_params = params[:q]&.to_unsafe_h
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
        :price,
        :why,
        :description,
        :requirements,
        :recipient_wallet_id,
        :transfer_type_id,
        :lockup_schedule_id,
        :commencement_date
      )
    end

    def transfer_update_params
      params.fetch(:award, {}).permit(:prioritized_at)
    end
end
