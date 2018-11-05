class AddCoinTypeToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :coin_type, :string
  end
end
