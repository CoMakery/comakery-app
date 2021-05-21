class AddBlockchainTransactionsCountToAwards < ActiveRecord::Migration[6.0]
  def up
    add_column :awards, :blockchain_transactions_count, :integer, default: 0
  end

  def down
    remove_column :awards, :blockchain_transactions_count
  end
end