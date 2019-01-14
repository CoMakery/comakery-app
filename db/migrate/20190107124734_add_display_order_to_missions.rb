class AddDisplayOrderToMissions < ActiveRecord::Migration[5.1]
  def change
    add_column :missions, :display_order, :integer
  end
end
