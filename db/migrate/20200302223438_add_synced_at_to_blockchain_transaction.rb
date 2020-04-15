class AddSyncedAtToBlockchainTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :blockchain_transactions, :synced_at, :datetime
    add_column :blockchain_transactions, :number_of_syncs, :integer, default: 0
  end
end
