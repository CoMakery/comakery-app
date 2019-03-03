class ChangeDefaultStatusForProjects < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:projects, :status, from: 0, to: 1)
  end
end
