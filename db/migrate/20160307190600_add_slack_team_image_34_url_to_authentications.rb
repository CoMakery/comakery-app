class AddSlackTeamImage34UrlToAuthentications < ActiveRecord::Migration[4.2]
  def change
    add_column :authentications, :slack_team_image_34_url, :string
  end
end
