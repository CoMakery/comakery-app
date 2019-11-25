class AddWhitelabelToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :whitelabel, :boolean
  end
end
