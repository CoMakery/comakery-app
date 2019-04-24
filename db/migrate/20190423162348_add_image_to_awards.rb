class AddImageToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :image_id, :string
    add_column :awards, :image_filename, :string
    add_column :awards, :image_content_size, :string
    add_column :awards, :image_content_type, :string
  end
end
