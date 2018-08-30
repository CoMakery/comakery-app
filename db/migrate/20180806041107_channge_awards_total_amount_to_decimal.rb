class ChanngeAwardsTotalAmountToDecimal < ActiveRecord::Migration[5.1]
  def up
    change_column :awards, :total_amount, :decimal
  end
  def down
    change_column :awards, :total_amount, :integer
  end
end
