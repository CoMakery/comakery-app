class AddEthereumTransactionDetailsToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :ethereum_transaction_success, :boolean
    add_column :awards, :ethereum_transaction_error, :string
  end
end
