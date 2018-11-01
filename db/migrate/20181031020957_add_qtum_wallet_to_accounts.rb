class AddQtumWalletToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :qtum_wallet, :string
  end
end
