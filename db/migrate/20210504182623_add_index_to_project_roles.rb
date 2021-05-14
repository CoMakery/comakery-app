class AddIndexToProjectRoles < ActiveRecord::Migration[6.0]
  def change
    add_index :project_roles, %i[account_id project_id], unique: true
  end
end
