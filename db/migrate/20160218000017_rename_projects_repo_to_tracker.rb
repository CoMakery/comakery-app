class RenameProjectsRepoToTracker < ActiveRecord::Migration[4.2]
  def change
    rename_column :projects, :repo, :tracker
  end
end
