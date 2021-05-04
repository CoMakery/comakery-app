class AddIndexToProjectRoles < ActiveRecord::Migration[6.0]
  def change
    add_index :project_roles, %i[project_id account_id], unique: true
  end
end
