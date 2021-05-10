class CreateTransactionBatches < ActiveRecord::Migration[6.0]
  def change
    create_table :transaction_batches do |t|
      t.timestamps
    end
  end
end
