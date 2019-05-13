class AddImagesToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :square_image_id, :string
    add_column :projects, :square_image_filename, :string
    add_column :projects, :square_image_content_size, :string
    add_column :projects, :square_image_content_type, :string
    add_column :projects, :panoramic_image_id, :string
    add_column :projects, :panoramic_image_filename, :string
    add_column :projects, :panoramic_image_content_size, :string
    add_column :projects, :panoramic_image_content_type, :string
  end
end
