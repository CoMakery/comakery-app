class AddEthereumContractAddressToProject < ActiveRecord::Migration
  def change
    add_column :projects, :ethereum_contract_address, :string
  end
end
