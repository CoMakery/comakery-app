class RemoveSpecialtyReferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :accounts, :deprecated_specialty

    remove_column :accounts, :specialty_id

    remove_column :award_types, :specialty_id

    remove_column :awards, :specialty_id
  end
end
