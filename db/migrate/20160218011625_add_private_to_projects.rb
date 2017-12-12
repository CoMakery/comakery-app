class AddPrivateToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :public, :boolean, null: false, default: false
  end
end
