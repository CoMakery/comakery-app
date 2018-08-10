class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :team_id
      t.string :name
      t.string :domain
      t.string :provider
      t.string :image

      t.timestamps
    end
  end
end
