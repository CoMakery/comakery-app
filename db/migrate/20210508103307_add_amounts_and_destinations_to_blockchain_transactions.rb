class AddAmountsAndDestinationsToBlockchainTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :blockchain_transactions, :amounts, :text, array: true, default: []
    add_column :blockchain_transactions, :destinations, :text, array: true, default: []
  end
end
