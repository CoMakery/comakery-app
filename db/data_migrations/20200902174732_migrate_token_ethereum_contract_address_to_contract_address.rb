class MigrateTokenEthereumContractAddressToContractAddress < ActiveRecord::DataMigration
  def up
    Token.where.not(ethereum_contract_address: nil).find_each do |t|
      t.update(contract_address: t.ethereum_contract_address)
    end
  end
end
