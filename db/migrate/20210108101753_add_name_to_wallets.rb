class AddNameToWallets < ActiveRecord::Migration[6.0]
  def change
    add_column :wallets, :name, :string
  end
end
