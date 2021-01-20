class AddColumnPrimaryWalletToWallets < ActiveRecord::Migration[6.0]
  def up
    add_column :wallets, :primary_wallet, :boolean, default: true

    add_index :wallets, [:account_id, :primary_wallet, :_blockchain], unique: true, where: "(primary_wallet IS TRUE)"
    remove_index :wallets, name: 'idx_blockchain_account_id'
    add_index :wallets, [:account_id, :_blockchain]

    change_column :wallets, :primary_wallet, :boolean, default: false
  end

  def down
    remove_column :wallets, :primary_wallet
    remove_index :wallets, [:account_id, :_blockchain]
    add_index :wallets, [:account_id, :_blockchain], name: "idx_blockchain_account_id", unique: true
  end
end
