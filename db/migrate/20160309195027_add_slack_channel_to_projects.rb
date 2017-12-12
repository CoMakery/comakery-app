class Project < ActiveRecord::Base; end

class AddSlackChannelToProjects < ActiveRecord::Migration[4.2]
  def up
    add_column :projects, :slack_channel, :string
    Project.update_all(["slack_channel = ?", "bot-testing"])
  end

  def down
    remove_column :projects, :slack_channel
  end
end
