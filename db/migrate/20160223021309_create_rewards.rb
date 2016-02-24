class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.integer :account_id, null: false
      t.integer :project_id, null: false
      t.integer :issuer_id, null: false
      t.integer :amount, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :rewards, :account_id
    add_index :rewards, [:project_id, :account_id]
  end
end
