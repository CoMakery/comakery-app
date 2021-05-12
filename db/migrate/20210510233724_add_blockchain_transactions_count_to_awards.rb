class AddBlockchainTransactionsCountToAwards < ActiveRecord::Migration[6.0]
  def up
    add_column :awards, :blockchain_transactions_count, :integer

    Award.find_each do |award|
      Award.reset_counters(award.id, :blockchain_transactions)
    end

    add_column :projects, :blockchain_transactions_count, :integer
    add_column :account_token_records, :blockchain_transactions_count, :integer
    add_column :tokens, :blockchain_transactions_count, :integer
    add_column :token_opt_ins, :blockchain_transactions_count, :integer
    add_column :transfer_rules, :blockchain_transactions_count, :integer
  end

  def down
    remove_column :projects, :blockchain_transactions_count, :integer
    remove_column :awards, :blockchain_transactions_count
    remove_column :tokens, :blockchain_transactions_count
    remove_column :token_opt_ins, :blockchain_transactions_count
    remove_column :transfer_rules, :blockchain_transactions_count
  end
end
