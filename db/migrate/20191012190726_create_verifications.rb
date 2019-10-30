class CreateVerifications < ActiveRecord::Migration[5.1]
  def change
    create_table :verifications do |t|
      t.belongs_to :account, foreign_key: true
      t.bigint :provider_id
      t.index :provider_id
      t.boolean :passed
      t.bigint :max_investment_usd

      t.timestamps
    end
  end
end
