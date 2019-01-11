class AddStatusToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :status, :integer, default: 0
    add_column :missions, :status, :integer, default: 0
  end
end
