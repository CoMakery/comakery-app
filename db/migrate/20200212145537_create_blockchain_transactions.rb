class CreateBlockchainTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :blockchain_transactions do |t|
      t.belongs_to :award, foreign_key: true
      t.integer :amount
      t.string :source
      t.string :destination
      t.integer :nonce
      t.string :contract_address
      t.integer :network
      t.string :tx_hash
      t.string :tx_raw
      t.integer :status, default: 0
      t.string :status_message

      t.timestamps
    end
  end
end
