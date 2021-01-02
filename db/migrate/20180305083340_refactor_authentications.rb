class RefactorAuthentications < ActiveRecord::Migration[5.1]
  def change
    remove_column :authentications, :slack_team_name, :string
    remove_column :authentications, :slack_team_id, :string
    # remove_column :authentications, :slack_user_name, :string
    # remove_column :authentications, :slack_first_name, :string
    # remove_column :authentications, :slack_last_name, :string
    change_column_null :authentications, :slack_user_name, true
    change_column_null :authentications, :slack_first_name, true
    change_column_null :authentications, :slack_last_name, true
    # remove_column :authentications, :slack_team_domain, :string
    # remove_column :authentications, :slack_team_image_34_url, :string
    # remove_column :authentications, :slack_team_image_132_url, :string
    # remove_column :authentications, :slack_image_32_url, :string
    rename_column :authentications, :slack_user_id, :uid
    rename_column :authentications, :slack_token, :token
  end
end
