class AddEthereumAddressToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :ethereum_address, :string
  end
end
