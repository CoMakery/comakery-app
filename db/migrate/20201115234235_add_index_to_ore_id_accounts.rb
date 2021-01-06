class AddIndexToOreIdAccounts < ActiveRecord::Migration[6.0]
  def change
    add_index :ore_id_accounts, :account_name, unique: true
  end
end
