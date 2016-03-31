class AddMaximumCoinsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :maximum_coins, :integer, null: false, default: 0
  end
end
