class AddLongIdToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :long_id, :string
  end
end
