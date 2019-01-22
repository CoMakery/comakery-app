class AddProjectIdToInterests < ActiveRecord::Migration[5.1]
  def change
    remove_column :interests, :project
    add_reference :interests, :project, index: true
  end
end
