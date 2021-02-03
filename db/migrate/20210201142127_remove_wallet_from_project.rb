class RemoveWalletFromProject < ActiveRecord::Migration[6.0]
  def change
    remove_column :projects, :hot_wallet_id
  end
end
