class AddManagerToAuthenticationTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :authentication_teams, :manager, :boolean, default: false
  end
end
