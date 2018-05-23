class AddVisibilityToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :visibility, :integer, default: 0
  end
end
