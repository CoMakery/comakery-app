class AddWalletRecoveryApiPublicKeyToMissions < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :wallet_recovery_api_public_key, :string
  end
end
