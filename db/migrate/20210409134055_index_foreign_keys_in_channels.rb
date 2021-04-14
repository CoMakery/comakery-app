class IndexForeignKeysInChannels < ActiveRecord::Migration[6.0]
  def change
    add_index :channels, :channel_id
  end
end
