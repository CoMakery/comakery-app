class AddTypeToBlockchainTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :blockchain_transactions, :type, :string, null: false, default: 'BlockchainTransactionAward'
  end
end
