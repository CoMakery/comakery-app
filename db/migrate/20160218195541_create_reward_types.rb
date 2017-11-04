class CreateRewardTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :reward_types do |t|
      t.references :project, null: false
      t.string :name, null: false
      t.integer :suggested_amount, null: false
      t.timestamps null: false
    end
  end
end
