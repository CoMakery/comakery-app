class IndexForeignKeysInTeams < ActiveRecord::Migration[6.0]
  def change
    add_index :teams, :team_id
  end
end
