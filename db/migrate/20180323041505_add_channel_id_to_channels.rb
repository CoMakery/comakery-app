class AddChannelIdToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :channel_id, :string
  end
end
