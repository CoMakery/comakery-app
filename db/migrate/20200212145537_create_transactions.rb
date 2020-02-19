class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.belongs_to :award, foreign_key: true
      t.decimal :amount
      t.string :source
      t.string :destination
      t.string :nonce
      t.string :contract_address
      t.integer :network
      t.string :hash
      t.string :raw

      t.timestamps
    end
  end
end
