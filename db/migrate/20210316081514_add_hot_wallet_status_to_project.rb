class AddHotWalletStatusToProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :hot_wallet_mode, :integer, default: 0, null: false
  end
end
