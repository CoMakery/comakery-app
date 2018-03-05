class CreateAwardLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :award_links do |t|
      t.integer :award_type_id
      t.decimal :quantity
      t.text :description
      t.string :status, default: 'available'
      t.string :token

      t.timestamps
    end
  end
end
