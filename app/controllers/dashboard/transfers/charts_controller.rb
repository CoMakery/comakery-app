# frozen_string_literal: true

module Dashboard
  module Transfers
    class ChartsController < ApplicationController
      skip_after_action :verify_policy_scoped, only: [:index]

      before_action :assign_project

      def index
        authorize @project, :transfers?

        @q = ::TransfersQuery.new(
          @project.awards.completed_or_cancelled.not_burned,
          params
        ).call

        relation = @q.result(distinct: true)

        @transfers = ::ReorderTransfersChartDataQuery.new(relation, params).call

        @transfers_not_burned_total = relation.sum(&:total_amount)

        @transfer_types_and_counts = relation.group(:source).pluck('awards.source, count(awards.source)').to_h

        @transfers_chart_colors_objects = @project.transfers_chart_colors_objects

        @transfer_type_name = TransferType.find_by(id: params.dig(:q, :transfer_type_id_eq))&.name

        render partial: 'dashboard/transfers/chart'
      end
    end
  end
end
