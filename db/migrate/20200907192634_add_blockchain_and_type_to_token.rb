class AddBlockchainAndTypeToToken < ActiveRecord::Migration[6.0]
  def change
    add_column :tokens, :_blockchain, :integer, default: 0, null: false
    add_column :tokens, :_token_type, :integer, default: 0, null: false
  end
end
