class AddDefaultValuesToProjects < ActiveRecord::Migration[5.1]
  def change
  	change_column_default(:projects, :require_confidentiality, from: nil, to: true)
  	change_column_default(:projects, :exclusive_contributions, from: nil, to: true)
  end
end
