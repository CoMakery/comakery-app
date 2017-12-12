class ChangePaymentAmountToDecimal < ActiveRecord::Migration[4.2]
  def up
    change_column :payments, :amount, :decimal
  end

  def down
    change_column :payments, :amount, :integer
  end
end
