class CreateWalletProvisions < ActiveRecord::Migration[6.0]
  def change
    create_table :wallet_provisions do |t|
      t.belongs_to :wallet, foreign_key: true, index: true
      t.belongs_to :token, foreign_key: true, index: true
      t.integer :stage, null: false, default: 0

      t.timestamps
    end
  end
end
