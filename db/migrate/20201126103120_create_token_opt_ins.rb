class CreateTokenOptIns < ActiveRecord::Migration[6.0]
  def change
    create_table :token_opt_ins do |t|
      t.references :wallet, null: false, foreign_key: true, index: true
      t.references :token, null: false, foreign_key: true, index: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
