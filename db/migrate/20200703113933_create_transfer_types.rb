class CreateTransferTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :transfer_types do |t|
      t.belongs_to :project, foreign_key: true
      t.string :name
      t.boolean :default, null: false, default: false

      t.timestamps
    end
  end
end
