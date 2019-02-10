class ChangeDefaultVisibilityForProjects < ActiveRecord::Migration[5.1]
  def change
  	change_column_default(:projects, :visibility, 1)
  end
end
