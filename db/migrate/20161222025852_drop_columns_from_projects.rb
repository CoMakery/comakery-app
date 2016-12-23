class DropColumnsFromProjects < ActiveRecord::Migration
  def up
    remove_columns(:projects, :minimum_revenue, :minimum_payment)
  end

  def down
    add_column :projects, :minimum_payment, :integer
    add_column :projects, :minimum_revenue, :integer
  end
end
