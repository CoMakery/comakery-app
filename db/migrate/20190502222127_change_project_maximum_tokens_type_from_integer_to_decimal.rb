class ChangeProjectMaximumTokensTypeFromIntegerToDecimal < ActiveRecord::Migration[5.1]
  def change
  	change_column :projects, :maximum_tokens, :decimal
  end
end
