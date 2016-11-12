class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :project_id
      t.integer :issuer_id
      t.integer :recipient_id
      t.integer :amount

      t.timestamps null: false
    end
  end
end
