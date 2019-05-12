class RemoveSpecialtyStringFromAwardType < ActiveRecord::Migration[5.1]
  def change
    remove_column :award_types, :specialty, :string
  end
end
