class AddColumReferenceWalletToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :recipient_wallet_id, :bigint
    add_foreign_key :awards, :wallets, column: :recipient_wallet_id
  end
end
