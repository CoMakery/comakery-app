class CreateInterests < ActiveRecord::Migration[5.1]
  def change
    create_table :interests do |t|
      t.belongs_to :account, foreign_key: true
      t.string :protocol
      t.string :project

      t.timestamps
    end
  end
end
