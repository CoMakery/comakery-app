class AddSpecialtiesId < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :specialty_id, :integer
    add_column :interests, :specialty_id, :integer
    add_column :award_types, :specialty_id, :integer
  end
end
