class AddPublishedToAwardTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :award_types, :published, :bool, default: false
  end
end
