class CreateWallets < ActiveRecord::Migration[6.0]
  def change
    create_table :wallets do |t|
      t.belongs_to :account, foreign_key: true
      t.string :address, null: false
      t.integer :_blockchain, null: false, default: 0
      t.integer :state, null: false, default: 0
      t.integer :source, null: false, default: 0
      t.index ["_blockchain", "account_id"], name: "idx_blockchain_account_id", unique: true

      t.timestamps
    end
  end
end
