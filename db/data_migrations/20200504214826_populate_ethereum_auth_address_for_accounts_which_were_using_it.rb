class PopulateEthereumAuthAddressForAccountsWhichWereUsingIt < ActiveRecord::DataMigration
  def up
    Account.migrate_ethereum_wallet_to_ethereum_auth_address
  end
end
