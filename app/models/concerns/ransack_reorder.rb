module RansackReorder
  extend ActiveSupport::Concern

  included do
    def self.ransack_reorder(order_params, default: :created_at)
      scope = reorder(default)
      return scope unless order_params

      order_params = order_params.join(', ') if order_params.is_a?(Array)
      order_column, direction = order_params.split(' ')
      order_string =
        if order_column.in?(column_names)
          "#{order_column} #{direction}"
        elsif order_string == 'issuer_first_name'
          scope = scope.joins(:issuer)
          "accounts.issuer_first_name #{direction}, accounts.issuer_last_name #{direction}"
        else
          default
        end
      scope.reorder(order_string)
    end
  end
end
