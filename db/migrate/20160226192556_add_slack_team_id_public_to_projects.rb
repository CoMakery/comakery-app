class AddSlackTeamIdPublicToProjects < ActiveRecord::Migration
  def change
    remove_index :projects, column: :slack_team_id
    add_index :projects, [:slack_team_id, :public]
  end
end
