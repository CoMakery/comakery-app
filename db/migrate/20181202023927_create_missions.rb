class CreateMissions < ActiveRecord::Migration[5.1]
  def change
    create_table :missions do |t|
      t.string :name, limit: 100
      t.string :subtitle, limit: 140
      t.text :description, limit: 250
      t.string :logo_id
      t.string :logo_filename
      t.string :logo_content_size
      t.string :logo_content_type
      t.string :image_id
      t.string :image_filename
      t.string :image_content_size
      t.string :image_content_type

      t.timestamps
    end
  end
end
