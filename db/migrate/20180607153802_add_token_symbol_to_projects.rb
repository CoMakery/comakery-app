class AddTokenSymbolToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :token_symbol, :string
  end
end
