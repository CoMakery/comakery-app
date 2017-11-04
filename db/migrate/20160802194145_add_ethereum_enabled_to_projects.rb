class AddEthereumEnabledToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :ethereum_enabled, :boolean, default: false
  end
end
