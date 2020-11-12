class CreateOreIds < ActiveRecord::Migration[6.0]
  def change
    create_table :ore_ids do |t|
      t.string :account_name
      t.belongs_to :account, foreign_key: true

      t.timestamps
    end
  end
end
