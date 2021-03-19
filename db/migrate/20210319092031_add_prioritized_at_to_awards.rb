class AddPrioritizedAtToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :prioritized_at, :datetime
  end
end
