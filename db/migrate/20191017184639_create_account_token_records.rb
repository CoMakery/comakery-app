class CreateAccountTokenRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :account_token_records do |t|
      t.belongs_to :account, foreign_key: true
      t.belongs_to :token, foreign_key: true
      t.belongs_to :reg_group, foreign_key: true
      t.bigint :max_balance
      t.boolean :account_frozen
      t.datetime :lockup_until
      t.datetime :synced_at

      t.timestamps
    end
  end
end
