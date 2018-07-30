class AddDecimalPlacesToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :decimal_places, :integer, deafault: 0
  end
end
