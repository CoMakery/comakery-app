# frozen_string_literal: true

module Dashboard
  module Transfers
    class ChartsController < ApplicationController
      skip_before_action :require_login, only: [:index]

      skip_after_action :verify_policy_scoped, only: [:index]

      before_action :assign_project

      def index
        authorize @project, :transfers?

        @unfiltered_transfers = @project.awards.completed_or_cancelled.not_burned

        @q = ::SearchTransfersQuery.new(
          @unfiltered_transfers,
          params
        ).call

        @transfers = @q.result(distinct: true).reorder('')

        @transfer_type_counts = @transfers.group(:source).pluck(:source, 'count(awards.source)').to_h

        @transfers_chart_colors_objects = @project.transfers_chart_colors_objects

        @transfer_type_name = TransferType.find_by(id: params.dig(:q, :transfer_type_id_eq))&.name

        render partial: 'dashboard/transfers/chart'
      end
    end
  end
end
