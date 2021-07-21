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

        @transfer_type_name = TransferType.find_by(id: params.dig(:q, :transfer_type_id_eq))&.name

        @transfer_type_counts = @transfers
                                  .group(:transfer_type_id)
                                  .pluck(:transfer_type_id, 'count(awards.transfer_type_id)')
                                  .to_h

        render partial: 'dashboard/transfers/chart'
      end
    end
  end
end
