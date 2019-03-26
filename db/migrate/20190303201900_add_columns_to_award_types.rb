class AddColumnsToAwardTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :award_types, :goal, :text
    add_column :award_types, :specialty, :string
  end
end
