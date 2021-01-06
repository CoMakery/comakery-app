class RemoveStateFromWallets < ActiveRecord::Migration[6.0]
  def change
    remove_column :wallets, :state, :integer
  end
end
