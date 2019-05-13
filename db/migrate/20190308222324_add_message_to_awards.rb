class AddMessageToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :message, :text
  end
end
