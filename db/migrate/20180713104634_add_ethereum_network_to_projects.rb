class AddEthereumNetworkToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :ethereum_network, :string
  end
end
