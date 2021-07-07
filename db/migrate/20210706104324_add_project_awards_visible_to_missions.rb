class AddProjectAwardsVisibleToMissions < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :project_awards_visible, :boolean, default: false, null: false
  end
end
