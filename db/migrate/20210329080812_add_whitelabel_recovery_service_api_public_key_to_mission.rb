class AddWhitelabelRecoveryServiceApiPublicKeyToMission < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :whitelabel_recovery_service_api_public_key, :string
  end
end
