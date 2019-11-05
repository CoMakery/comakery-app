class AddSyncedAtToToken < ActiveRecord::Migration[5.1]
  def change
    add_column :tokens, :synced_at, :datetime
  end
end
