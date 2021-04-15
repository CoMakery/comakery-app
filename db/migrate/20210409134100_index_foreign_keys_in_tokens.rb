class IndexForeignKeysInTokens < ActiveRecord::Migration[6.0]
  def change
    add_index :tokens, :logo_image_id
  end
end
