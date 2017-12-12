class RenameEthereumAddressToEthereumWalletOnAccounts < ActiveRecord::Migration[4.2]
  def change
    rename_column :accounts, :ethereum_address, :ethereum_wallet
  end
end
