class IndexProjects < ActiveRecord::Migration[4.2]
  def change
    change_column :projects, :title, :string, null: false
    add_index :projects, :public
  end
end
