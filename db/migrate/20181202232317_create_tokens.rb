class CreateTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :tokens do |t|
      t.string :name
      t.string :coin_type
      t.integer :denomination, default: 0, null: false
      t.boolean :ethereum_enabled, default: false
      t.string :ethereum_network
      t.string :blockchain_network
      t.string :contract_address
      t.string :ethereum_contract_address
      t.string :symbol
      t.integer :decimal_places
      t.string :logo_image_id
      t.string :logo_image_filename
      t.string :logo_image_content_size
      t.string :logo_image_content_type

      t.timestamps
    end
  end
end
