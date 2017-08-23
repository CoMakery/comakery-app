class RenameProjectMaximumCoinsToMaximumTokens < ActiveRecord::Migration
  def change
    rename_column :projects, :maximum_coins, :maximum_tokens
  end
end
