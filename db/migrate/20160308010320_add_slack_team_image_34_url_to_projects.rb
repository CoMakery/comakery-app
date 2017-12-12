class AddSlackTeamImage34UrlToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :slack_team_image_34_url, :string
  end
end
