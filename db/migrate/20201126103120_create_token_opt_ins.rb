class CreateTokenOptIns < ActiveRecord::Migration[6.0]
  def change
    create_table :token_opt_ins do |t|
      t.references :wallet, null: false, foreign_key: true, index: true
      t.references :token, null: false, foreign_key: true, index: true
      t.integer :status, null: false, default: 0 # pending

      t.timestamps
    end

    add_index :token_opt_ins, %i[wallet_id token_id], unique: true
  end
end
