class CreateInvites < ActiveRecord::Migration[6.0]
  def change
    create_table :invites do |t|
      t.string :email, null: false
      t.string :token, null: false, index: { unique: true }
      t.string :role, null: false
      t.boolean :accepted, default: false
      t.integer :invitable_id
      t.string :invitable_type

      t.timestamps
    end
  end
end
