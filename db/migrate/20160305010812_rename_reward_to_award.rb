class RenameRewardToAward < ActiveRecord::Migration[4.2]
  def up
    rename_column :rewards, :reward_type_id, :award_type_id
    rename_table :rewards, :awards
    rename_table :reward_types, :award_types
  end

  def down
    rename_column :awards, :award_type_id, :reward_type_id
    rename_table :awards, :rewards
    rename_table :award_types, :reward_types
  end
end
