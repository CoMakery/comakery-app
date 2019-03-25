class ChangeDefaultVisibiltyForProjects < ActiveRecord::Migration[5.1]
  def change
  	change_column_default(:projects, :visibility, from: 1, to: 0)
  end
end
