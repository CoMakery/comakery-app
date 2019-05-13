class RenameSpecialtyToDeprecatedSpecialtyInAccount < ActiveRecord::Migration[5.1]
  def change
    rename_column :accounts, :specialty, :deprecated_specialty
  end
end
