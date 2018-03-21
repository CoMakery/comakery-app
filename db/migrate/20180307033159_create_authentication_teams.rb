class CreateAuthenticationTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :authentication_teams do |t|
      t.string      :provider_team_id, required: true
      t.integer     :authentication_id, required: true
      t.timestamps
    end
    remove_column :authentications, :provider_team_id, :integer
  end

end
