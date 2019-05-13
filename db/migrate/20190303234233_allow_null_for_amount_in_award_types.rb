class AllowNullForAmountInAwardTypes < ActiveRecord::Migration[5.1]
  def change
  	change_column_null :award_types, :amount, true
  end
end
