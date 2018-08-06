class ChanngeAwardsTotalAmountToDecimal < ActiveRecord::Migration[5.1]
  def change
    change_column :awards, :total_amount, :decimal
  end
end
