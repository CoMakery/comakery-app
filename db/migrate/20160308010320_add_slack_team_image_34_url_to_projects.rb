class AddSlackTeamImage34UrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :slack_team_image_34_url, :string
  end
end
