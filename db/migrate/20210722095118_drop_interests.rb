class DropInterests < ActiveRecord::Migration[6.0]
  def change
    drop_table :interests

    remove_column :projects, :interests_count
  end
end
