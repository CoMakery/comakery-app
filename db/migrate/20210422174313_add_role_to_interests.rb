class AddRoleToInterests < ActiveRecord::Migration[6.0]
  def change
    add_column :interests, :role, :integer, default: 0, null: false
  end
end
