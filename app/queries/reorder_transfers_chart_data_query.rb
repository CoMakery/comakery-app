# frozen_string_literal: true

class ReorderTransfersChartDataQuery
  def initialize(relation, params)
    @relation = relation
    @params = params
  end

  def call
    relation.includes(relationships).ransack_reorder(reorder_params)
  end

  private

    attr_reader :relation, :params

    def relationships
      [
        :issuer,
        :transfer_type,
        :token
      ]
    end

    def reorder_params
      params.dig(:q, :s)
    end
end

