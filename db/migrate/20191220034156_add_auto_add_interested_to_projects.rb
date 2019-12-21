class AddAutoAddInterestedToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :auto_add_interest, :boolean, default: false, null: false
  end
end
