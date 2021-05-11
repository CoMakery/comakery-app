class MigrateBlockchainTransactionsAssociation < ActiveRecord::DataMigration
  def up
    BlockchainTransaction.find_each do |t|
      if t.blockchain_transactable_type
        transactable = t.blockchain_transactable_type.constantize.find(t.blockchain_transactable_id)
        t.blockchain_transactables = transactable
        t.save
      end
    end
  end
end
