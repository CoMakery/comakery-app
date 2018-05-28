class AddSlackChannelToProjects < ActiveRecord::Migration[4.2]
  def up
    add_column :projects, :slack_channel, :string
  end

  def down
    remove_column :projects, :slack_channel
  end
end
