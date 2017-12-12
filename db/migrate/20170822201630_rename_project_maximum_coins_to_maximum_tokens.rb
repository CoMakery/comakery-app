class RenameProjectMaximumCoinsToMaximumTokens < ActiveRecord::Migration[4.2]
  def change
    rename_column :projects, :maximum_coins, :maximum_tokens
  end
end
