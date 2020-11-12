module RansackReorder
  extend ActiveSupport::Concern

  included do
    def self.special_orders
      @special_orders || []
    end

    def self.add_special_orders(orders_list)
      @special_orders = orders_list
    end

    def self.ransack_reorder(order_param, default: { created_at: :desc })
      scope = reorder(default)
      return scope unless order_param

      order_column, direction = order_param.split(' ')
      direction = direction == 'desc' ? 'desc' : 'asc'
      order_param =
        if order_column.in?(column_names)
          "#{order_column} #{direction}"
        elsif order_column.in?(special_orders)
          scope = send("prepare_ordering_by_#{order_column}", scope)
          send("#{order_column}_order_string", direction)
        else
          default
        end
      scope.reorder(order_param)
    end
  end
end
