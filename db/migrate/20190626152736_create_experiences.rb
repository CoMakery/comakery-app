class CreateExperiences < ActiveRecord::Migration[5.1]
  def change
    create_table :experiences do |t|
      t.belongs_to :account, foreign_key: true
      t.belongs_to :specialty, foreign_key: true
      t.integer :level, default: 0

      t.timestamps
    end
  end
end
