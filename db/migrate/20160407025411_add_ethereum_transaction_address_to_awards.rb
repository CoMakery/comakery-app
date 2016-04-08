class AddEthereumTransactionAddressToAwards < ActiveRecord::Migration
  def change
    add_column :awards, :ethereum_transaction_address, :string
  end
end
