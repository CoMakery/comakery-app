module Dashboard
  class TransfersController < ApplicationController
    skip_before_action :require_login, only: %i[index show]
    skip_after_action :verify_policy_scoped, only: %i[index show]

    before_action :assign_project

    fragment_cache_key { "#{current_user&.id}/#{@project.id}/#{@project.token&.updated_at}" }

    def index
      authorize @project, :transfers?

      @q = TransfersQuery.new(
        @project.awards.completed_or_cancelled,
        params
      ).call

      @transfers = OrderedTransfersQuery.new(
        @q.result(distinct: true),
        params
      ).call

      if params.fetch(:page, 1).to_i > 1 && @transfers.out_of_range?
        flash[:notice] = "Displaying first page of filtered results. " \
                         "Not enough results to display page #{params.fetch(:page, 1).to_i}."
      end
    end

    def new
      authorize @project, :create_transfer?

      @transfer = Award.new(transfer_params)
    end

    def update
      authorize @project, :update_transfer?

      result = Transfers::Update.call(project: @project, award_id: params[:id], transfer_params: transfer_params)

      if result.success?
        redirect_to project_dashboard_transfers_path(@project), notice: 'Transfer Updated'
      else
        redirect_to project_dashboard_transfers_path(@project), flash: { error: result.error }
      end
    end

    def create
      authorize @project, :create_transfer?

      result = Transfers::Create.call(
        issuer: current_account,
        award_type: @project.default_award_type,
        account_id: params[:award][:account_id],
        transfer_params: transfer_params
      )

      if result.success?
        redirect_to project_dashboard_transfers_path(@project), flash: { notice: 'Transfer Created' }
      else
        redirect_to project_dashboard_transfers_path(@project), flash: { error: result.error }
      end
    end

    def edit
      authorize @project, :update_transfer?

      @transfer = @project.awards.find(params[:id])
    end

    def show
      authorize @project, :transfers?

      @transfer = @project.awards.find(params[:id])
    end

    def export
      authorize @project, :export_transfers?

      ProjectExportTransfersJob.perform_later(@project.id, current_account.id)

      redirect_to project_dashboard_transfers_path(@project), notice: "CSV will be sent to #{current_account.email}"
    end

    def prioritize
      authorize @project, :update_transfer?
      @transfer = @project.awards.find(params[:id])

      @transfer.update(prioritized_at: Time.zone.now)
      redirect_to project_dashboard_transfers_path(@project), flash: { notice: 'Transfer will be sent soon' }
    end

    private

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
  end
end
