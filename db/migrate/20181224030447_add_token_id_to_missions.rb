class AddTokenIdToMissions < ActiveRecord::Migration[5.1]
  def change
    add_column :missions, :token_id, :integer
  end
end
