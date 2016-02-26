class Project < ActiveRecord::Base; end

class AddSlackTeamNameToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :slack_team_name, :string
    Project.connection.execute("update projects set slack_team_name = (select authentications.slack_team_name from authentications where projects.slack_team_id = authentications.slack_team_id);")
  end

  def down
    remove_column :projects, :slack_team_name
  end
end
