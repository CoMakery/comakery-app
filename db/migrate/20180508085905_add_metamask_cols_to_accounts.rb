class AddMetamaskColsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :public_address, :string
    add_column :accounts, :nonce, :string
    add_column :accounts, :network_id, :string
    add_column :accounts, :system_email, :boolean, default: false

    add_index :accounts, :public_address
  end
end
