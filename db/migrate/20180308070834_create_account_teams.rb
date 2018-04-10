class CreateAccountTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :account_teams do |t|
      t.integer :account_id
      t.integer :team_id

      t.timestamps
    end
  end
end
