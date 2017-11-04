class AddMaximumCoinsToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :maximum_coins, :integer, null: false, default: 0
  end
end
