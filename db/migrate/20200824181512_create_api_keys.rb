class CreateApiKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :api_keys do |t|
      t.references :api_authorizable, polymorphic: true
      t.string :key, limit: 32

      t.timestamps
    end
  end
end
