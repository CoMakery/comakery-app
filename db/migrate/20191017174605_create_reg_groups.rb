class CreateRegGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :reg_groups do |t|
      t.belongs_to :token, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
