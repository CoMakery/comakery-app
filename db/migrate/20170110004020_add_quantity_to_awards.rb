class AddQuantityToAwards < ActiveRecord::Migration
  def change
    add_column :awards, :quantity, :numeric, default: 1.0
    add_column :awards, :total_amount, :numeric, precision: 18, scale:0
    add_column :awards, :unit_amount, :numeric, precision: 18, scale: 0
  end
end
