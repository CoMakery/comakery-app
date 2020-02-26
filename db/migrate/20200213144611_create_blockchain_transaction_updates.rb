class CreateBlockchainTransactionUpdates < ActiveRecord::Migration[6.0]
  def change
    create_table :blockchain_transaction_updates do |t|
      t.belongs_to :blockchain_transaction, foreign_key: true, index: {name: 'index_blockchain_tx_updates_on_blockchain_tx_id'}
      t.integer :status, default: 0
      t.string :status_message

      t.timestamps
    end
  end
end
