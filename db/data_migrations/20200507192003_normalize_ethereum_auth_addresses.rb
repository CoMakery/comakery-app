class NormalizeEthereumAuthAddresses < ActiveRecord::DataMigration
  def up
    Account.where.not(ethereum_auth_address: nil).find_each do |a|
      a.update(ethereum_auth_address: a.ethereum_auth_address)
    end
  end
end
