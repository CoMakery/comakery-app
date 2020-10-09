class RenameEthereumColumnsForAwards < ActiveRecord::Migration[6.0]
  def change
    rename_column :awards, :ethereum_transaction_success, :transaction_success
    rename_column :awards, :ethereum_transaction_error, :transaction_error
  end
end
