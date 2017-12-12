class AddLicenseFinalizedColumnToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :license_finalized, :boolean, default: false, null: false
  end
end
