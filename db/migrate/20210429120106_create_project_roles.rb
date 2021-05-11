class CreateProjectRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :project_roles do |t|
      t.references :account, null: false, foreign_key: true, index: true
      t.references :project, null: false, foreign_key: true, index: true
      t.integer :role, default: 0, null: false, index: true

      t.timestamps
    end
  end
end
