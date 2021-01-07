class AddColumnPrimaryWalletToWallets < ActiveRecord::Migration[6.0]
  def up
    add_column :wallets, :primary_wallet, :boolean, default: false
    remove_index :wallets, name: 'idx_blockchain_account_id'
    add_index :wallets, [:account_id, :_blockchain]
    add_index :wallets, [:account_id, :primary_wallet, :_blockchain], unique: true, where: "(primary_wallet IS TRUE)"

    execute <<-SQL
      UPDATE wallets
      SET primary_wallet=true
      FROM (
        SELECT 
          id,
          rank()
        OVER (PARTITION BY account_id, _blockchain ORDER BY id ASC)
        FROM wallets
      ) wp
      WHERE wallets.id=wp.id AND wp.rank=1
    SQL
  end

  def down
    remove_column :wallets, :primary_wallet
    remove_index :wallets, [:account_id, :_blockchain]
    add_index :wallets, [:account_id, :_blockchain], name: "idx_blockchain_account_id", unique: true
  end
end
