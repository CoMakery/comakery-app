class AddBlockchainIndexToTokens < ActiveRecord::Migration[6.0]
  def change
    add_index :tokens, :_blockchain
  end
end
