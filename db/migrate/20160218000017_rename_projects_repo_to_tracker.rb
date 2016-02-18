class RenameProjectsRepoToTracker < ActiveRecord::Migration
  def change
    rename_column :projects, :repo, :tracker
  end
end
