# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class PopulateTokenForBlockchainTransaction < ActiveRecord::DataMigration
  def up
    BlockchainTransaction.where(token: nil).find_each do |t|
      t.update_column(:token_id, t.blockchain_transactable.token.id)
    end
  end
end
