class AddFeaturedColumnToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :featured, :integer, default: nil
  end
end
