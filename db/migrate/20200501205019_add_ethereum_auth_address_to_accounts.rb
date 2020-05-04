class AddEthereumAuthAddressToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :ethereum_auth_address, :string, limit: 42
  end
end
