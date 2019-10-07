class AddCounterCacheAwardAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :assignments_count, :integer, default: 0
  end
end
