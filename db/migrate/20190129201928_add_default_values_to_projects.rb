class AddDefaultValuesToProjects < ActiveRecord::Migration[5.1]
  def change
  	change_column_default(:projects, :require_confidentiality, true)
  	change_column_default(:projects, :exclusive_contributions, true)
  end
end
