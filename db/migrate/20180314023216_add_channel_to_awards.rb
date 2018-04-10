class AddChannelToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :channel_id, :integer
    add_column :awards, :uid, :string
  end
end
