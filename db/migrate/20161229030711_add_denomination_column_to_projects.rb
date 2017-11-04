class AddDenominationColumnToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :denomination, :integer, default: 0, null: false
  end
end
