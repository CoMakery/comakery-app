class ChangeTypeOfBaseUnitValueForBalance < ActiveRecord::Migration[6.0]
  def change
    change_column :balances, :base_unit_value, :decimal, precision: 78, scale: 0
  end
end
