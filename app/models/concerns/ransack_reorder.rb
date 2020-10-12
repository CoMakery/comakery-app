module RansackReorder
  extend ActiveSupport::Concern

  included do
    def self.add_special_orders(orders_list)
      @special_orders = orders_list
    end

    def self.ransack_reorder(order_param, default: :created_at)
      scope = reorder(default)
      return scope unless order_param

      order_column, direction = order_param.split(' ')
      order_param =
        if order_column.in?(column_names)
          "#{order_column} #{direction}"
        elsif order_param.in?(@special_orders)
          scope = send("prepare_ordering_by_#{order_param}", scope)
          send("#{order_param}_order_string", direction)
        else
          default
        end
      scope.reorder(order_param)
    end
  end
end
