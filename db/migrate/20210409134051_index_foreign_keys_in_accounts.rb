class IndexForeignKeysInAccounts < ActiveRecord::Migration[6.0]
  def change
    add_index :accounts, :image_id
    add_index :accounts, :latest_verification_id
    add_index :accounts, :managed_account_id
    add_index :accounts, :network_id
    add_index :accounts, :specialty_id
  end
end
