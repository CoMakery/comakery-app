class AddTeamIdToAuthenticationTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :authentication_teams, :account_id, :integer
    add_column :authentication_teams, :team_id, :integer
    remove_column :authentication_teams, :provider_team_id, :string
    drop_table :account_teams
  end
end
