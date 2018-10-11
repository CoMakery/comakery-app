class AddIndexesForAccessProjects < ActiveRecord::Migration[5.1]
  def change
    add_index :channels, :project_id
    add_index :channels, :team_id
    add_index :authentication_teams, :authentication_id
    add_index :authentication_teams, :team_id
    add_index :authentication_teams, :account_id
  end
end
