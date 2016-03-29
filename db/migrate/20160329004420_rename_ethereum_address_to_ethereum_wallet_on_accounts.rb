class RenameEthereumAddressToEthereumWalletOnAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :ethereum_address, :ethereum_wallet
  end
end
