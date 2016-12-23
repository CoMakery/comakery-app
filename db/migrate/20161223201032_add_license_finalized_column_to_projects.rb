class AddLicenseFinalizedColumnToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :license_finalized, :boolean, default: false, null: false
  end
end
