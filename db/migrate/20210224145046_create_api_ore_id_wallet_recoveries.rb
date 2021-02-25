class CreateApiOreIdWalletRecoveries < ActiveRecord::Migration[6.0]
  def change
    create_table :api_ore_id_wallet_recoveries do |t|
      t.belongs_to :api_request_log, foreign_key: true, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
