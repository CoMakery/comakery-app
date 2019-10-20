class CreateTransferRules < ActiveRecord::Migration[5.1]
  def change
    create_table :transfer_rules do |t|
      t.belongs_to :token, foreign_key: true
      t.bigint :sending_group_id
      t.bigint :receiving_group_id
      t.datetime :lockup_until
      t.datetime :synced_at

      t.timestamps
    end
  end
end
