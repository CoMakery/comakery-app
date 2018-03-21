class AddIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :account_roles, :account_id

    add_index :award_types, :project_id

    add_index :authentications, :account_id

    add_index :awards, :award_type_id

    add_index :payments, :project_id

    add_index :revenues, :project_id
    add_index :revenues, :recorded_by_id
  end
end
