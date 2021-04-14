class IndexForeignKeysInProjects < ActiveRecord::Migration[6.0]
  def change
    add_index :projects, :image_id
    add_index :projects, :long_id
    add_index :projects, :panoramic_image_id
    add_index :projects, :square_image_id
  end
end
