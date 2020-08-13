class AddConstellationWalletToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :constellation_wallet, :string, limit: 40
  end
end
