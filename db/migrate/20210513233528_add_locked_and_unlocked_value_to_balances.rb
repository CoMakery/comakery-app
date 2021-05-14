class AddLockedAndUnlockedValueToBalances < ActiveRecord::Migration[6.0]
  def change
    add_column :balances, :base_unit_locked_value, :decimal, precision: 78, default: "0", null: false
    add_column :balances, :base_unit_unlocked_value, :decimal, precision: 78, default: "0", null: false
  end
end
