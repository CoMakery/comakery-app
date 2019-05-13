class AddExperienceLevelToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :experience_level, :integer, default: 0
  end
end
