class Authentication < ActiveRecord::Base; end
class Project < ActiveRecord::Base; end

class AddSlackTeamToAuthenticationsAndProjects < ActiveRecord::Migration
  def up
    Authentication.destroy_all
    Project.destroy_all

    add_column :authentications, :slack_team_name, :string, null: false
    add_column :authentications, :slack_team_id, :string, null: false
    add_column :authentications, :slack_user_id, :string, null: false
    add_column :authentications, :slack_token, :string, null: false
    change_column :authentications, :uid, :string, null: true
    add_column :projects, :slack_team_id, :string, null: false
    add_index :authentications, :slack_team_id
    add_index :projects, :slack_team_id
  end

  def down
    Authentication.destroy_all
    Project.destroy_all

    remove_column :authentications, :slack_team_name
    remove_column :authentications, :slack_team_id
    remove_column :authentications, :slack_user_id
    remove_column :authentications, :slack_token
    remove_column :projects, :slack_team_id
    change_column :authentications, :uid, :string, null: false
  end
end
