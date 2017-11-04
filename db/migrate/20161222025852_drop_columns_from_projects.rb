class DropColumnsFromProjects < ActiveRecord::Migration[4.2]
  def up
    remove_columns(:projects, :minimum_revenue, :minimum_payment)
  end

  def down
    add_column :projects, :minimum_payment, :integer
    add_column :projects, :minimum_revenue, :integer
  end
end
