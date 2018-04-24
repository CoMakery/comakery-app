class UpdateProjectVisibility < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :archived, :boolean
  end
end
