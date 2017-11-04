class AddEthereumAddressToAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :ethereum_address, :string
  end
end
