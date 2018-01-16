class ChangeDefaultPaymentTypeToProjectToken < ActiveRecord::Migration[5.1]
  def up
    change_column :projects, :payment_type, :integer, default: 1
  end

  def down
    change_column :projects, :payment_type, :integer, default: 0
  end
end
