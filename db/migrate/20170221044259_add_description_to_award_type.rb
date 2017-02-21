class AddDescriptionToAwardType < ActiveRecord::Migration
  def change
    add_column :award_types, :description, :text
  end
end
