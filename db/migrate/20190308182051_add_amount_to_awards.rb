class AddAmountToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :amount, :decimal
  end
end
