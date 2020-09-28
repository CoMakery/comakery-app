class CreateBalances < ActiveRecord::Migration[6.0]
  def change
    create_table :balances do |t|
      t.belongs_to :wallet, foreign_key: true
      t.belongs_to :token, foreign_key: true
      t.bigint :base_unit_value, null: false, default: 0
      t.index ["wallet_id", "token_id"], name: "idx_walled_id_token_id", unique: true

      t.timestamps
    end
  end
end
