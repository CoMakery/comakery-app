class IndexProjects < ActiveRecord::Migration
  def change
    change_column :projects, :title, :string, null: false
    add_index :projects, :public
  end
end
