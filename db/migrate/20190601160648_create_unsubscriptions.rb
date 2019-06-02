class CreateUnsubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :unsubscriptions do |t|
      t.string :email

      t.timestamps
    end

    add_index :unsubscriptions, :email, unique: true
  end
end
