class AddSourceToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :source, :integer, default: 0
  end
end
