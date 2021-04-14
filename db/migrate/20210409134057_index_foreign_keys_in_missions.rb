class IndexForeignKeysInMissions < ActiveRecord::Migration[6.0]
  def change
    add_index :missions, :image_id
    add_index :missions, :logo_id
    add_index :missions, :whitelabel_favicon_id
    add_index :missions, :whitelabel_logo_dark_id
    add_index :missions, :whitelabel_logo_id
  end
end
