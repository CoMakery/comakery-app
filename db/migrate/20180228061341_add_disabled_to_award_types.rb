class AddDisabledToAwardTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :award_types, :disabled, :boolean
  end
end
