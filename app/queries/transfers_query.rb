# frozen_string_literal: true

class TransfersQuery
  def initialize(relation, params)
    @relation = relation
    @params = params
  end

  def call
    relation = @relation.not_cancelled unless filter_params.eql?('cancelled')

    relation = @relation.ransack(search_params)

    relation
  end

  private

    attr_reader :relation, :params

    def filter_params
      params.fetch(:q, {}).fetch(:filter, {})
    end

    def search_params
      params[:q]
    end
end

