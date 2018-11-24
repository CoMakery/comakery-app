class AddBlockchainColsToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :blockchain_network, :string
    add_column :projects, :contract_address, :string
  end
end
