class AddColumnsToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :name, :string
    add_column :awards, :why, :text
    add_column :awards, :requirements, :text
    add_column :awards, :status, :integer, default: 0
  end
end
