class AddPriceToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :price, :decimal, precision: 14, scale: 2, default: 0
  end
end
