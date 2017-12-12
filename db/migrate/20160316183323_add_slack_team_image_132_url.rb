class AddSlackTeamImage132Url < ActiveRecord::Migration[4.2]
  def up
    add_column :authentications, :slack_team_image_132_url, :string
    add_column :projects,        :slack_team_image_132_url, :string

    # don't be blank; will be replaced on next login with large image:
    execute "update authentications set slack_team_image_132_url=slack_team_image_34_url"
    execute "update projects        set slack_team_image_132_url=slack_team_image_34_url"
  end

  def down
    remove_column :authentications, :slack_team_image_132_url
    remove_column :projects,        :slack_team_image_132_url
  end
end
