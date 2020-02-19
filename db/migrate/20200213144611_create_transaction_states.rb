class CreateTransactionStates < ActiveRecord::Migration[6.0]
  def change
    create_table :transaction_states do |t|
      t.belongs_to :transaction, foreign_key: true
      t.integer :status, default: 0
      t.string :status_message

      t.timestamps
    end
  end
end
