class AddQuantityToAwards < ActiveRecord::Migration
  def change
    add_column :awards, :quantity, :decimal, precision: 36, scale: 18, default: 1.0
    add_column :awards, :total_amount, :decimal, precision: 36, scale: 18 # ETH decimal precision
    add_column :awards, :unit_amount, :decimal, precision: 36, scale: 18
  end
end
