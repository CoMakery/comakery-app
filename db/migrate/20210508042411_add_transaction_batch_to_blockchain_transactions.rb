class AddTransactionBatchToBlockchainTransactions < ActiveRecord::Migration[6.0]
  def change
    add_reference :blockchain_transactions, :transaction_batch, foreign_key: true
  end
end
