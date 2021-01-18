class AddAddressBlockchainAccountIndexToWallets < ActiveRecord::Migration[6.0]
  def up
    ids_to_keep = Wallet.select('DISTINCT ON (account_id, address, _blockchain) *').map(&:id)
    Wallet.where.not(id: ids_to_keep).destroy_all
    add_index :wallets, [:account_id, :address, :_blockchain], unique: true
  end

  def down
    emove_index :wallets, [:account_id, :address, :_blockchain]
  end
end
