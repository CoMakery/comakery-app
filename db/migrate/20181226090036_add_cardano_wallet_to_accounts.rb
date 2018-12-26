class AddCardanoWalletToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :cardano_wallet, :string
  end
end
