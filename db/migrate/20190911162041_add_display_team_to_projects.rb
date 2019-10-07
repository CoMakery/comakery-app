class AddDisplayTeamToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :display_team, :bool, default: true
  end
end
