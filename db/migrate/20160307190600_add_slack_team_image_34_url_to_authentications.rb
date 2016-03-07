class AddSlackTeamImage34UrlToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :slack_team_image_34_url, :string
  end
end
