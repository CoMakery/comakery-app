class CreateChannels < ActiveRecord::Migration[5.1]
  def change
    create_table :channels do |t|
      t.integer :project_id
      t.integer :team_id
      t.string :name

      t.timestamps
    end
  end
end
