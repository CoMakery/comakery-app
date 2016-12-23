class AddDenominationColumnToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :denomination, :integer, default: 0, null: false
  end
end
