class DropRolesAndRelatedTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :roles do |t|
      t.string :name, null: false
      t.string :key, null: false
      t.timestamps
    end

    drop_table :account_roles do |t|
      t.belongs_to :account, null: false
      t.belongs_to :role, null: false
      t.timestamps
    end
  end
end
