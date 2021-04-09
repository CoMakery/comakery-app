class IndexForeignKeysInInterests < ActiveRecord::Migration[6.0]
  def change
    add_index :interests, :specialty_id
  end
end
