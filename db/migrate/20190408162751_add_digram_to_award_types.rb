class AddDigramToAwardTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :award_types, :diagram_id, :string
    add_column :award_types, :diagram_filename, :string
    add_column :award_types, :diagram_content_size, :string
    add_column :award_types, :diagram_content_type, :string
  end
end
