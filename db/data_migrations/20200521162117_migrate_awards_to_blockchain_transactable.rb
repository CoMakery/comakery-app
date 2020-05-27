class MigrateAwardsToBlockchainTransactable < ActiveRecord::DataMigration
  def up
    BlockchainTransaction.migrate_awards_to_blockchain_transactable
  end
end
