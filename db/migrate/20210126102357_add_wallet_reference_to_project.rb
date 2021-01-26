class AddWalletReferenceToProject < ActiveRecord::Migration[6.0]
  def change
    add_reference :projects, :hot_wallet, foreign_key: { to_table: :wallets }
  end
end
