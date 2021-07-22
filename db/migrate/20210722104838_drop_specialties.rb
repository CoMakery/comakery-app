class DropSpecialties < ActiveRecord::Migration[6.0]
  def change
    drop_table :specialties
  end
end
