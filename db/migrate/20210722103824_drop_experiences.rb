class DropExperiences < ActiveRecord::Migration[6.0]
  def change
    drop_table :experiences
  end
end
