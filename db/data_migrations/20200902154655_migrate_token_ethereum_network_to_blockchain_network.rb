class MigrateTokenEthereumNetworkToBlockchainNetwork < ActiveRecord::DataMigration
  def up
    Token.where.not(ethereum_network: nil).find_each do |t|
      t.update!(blockchain_network: t.ethereum_network.to_sym)
    end
  end
end
