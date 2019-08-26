class AddStateToAwardTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :award_types, :state, :integer, default: 0
  end
end
