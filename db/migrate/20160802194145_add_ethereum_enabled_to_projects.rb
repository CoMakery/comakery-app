class AddEthereumEnabledToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ethereum_enabled, :boolean, default: false
  end
end
