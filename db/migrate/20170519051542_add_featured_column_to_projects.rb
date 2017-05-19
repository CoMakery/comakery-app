class AddFeaturedColumnToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :featured, :integer, default: nil
  end
end
