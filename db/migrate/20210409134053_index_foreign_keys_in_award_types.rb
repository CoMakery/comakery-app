class IndexForeignKeysInAwardTypes < ActiveRecord::Migration[6.0]
  def change
    add_index :award_types, :diagram_id
    add_index :award_types, :specialty_id
  end
end
