class AddManagedColumnsToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :managed_account_id, :string, limit: 256
    add_reference :accounts, :managed_mission, foreign_key: { to_table: :missions }
    add_index :accounts, [:managed_mission_id, :managed_account_id], unique: true
  end
end
