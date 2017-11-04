class AddEthereumContractAddressToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :ethereum_contract_address, :string
  end
end
