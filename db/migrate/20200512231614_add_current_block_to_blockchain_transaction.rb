class AddCurrentBlockToBlockchainTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :blockchain_transactions, :current_block, :decimal, precision: 78, scale: 0
  end
end
