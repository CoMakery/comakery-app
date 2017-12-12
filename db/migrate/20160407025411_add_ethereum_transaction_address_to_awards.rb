class AddEthereumTransactionAddressToAwards < ActiveRecord::Migration[4.2]
  def change
    add_column :awards, :ethereum_transaction_address, :string
  end
end
