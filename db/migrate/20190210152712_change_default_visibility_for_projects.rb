class ChangeDefaultVisibilityForProjects < ActiveRecord::Migration[5.1]
  def change
  	change_column_default(:projects, :visibility, from: 0, to: 1)
  end
end
