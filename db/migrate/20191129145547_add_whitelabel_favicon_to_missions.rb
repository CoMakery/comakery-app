class AddWhitelabelFaviconToMissions < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :whitelabel_favicon_id, :string
    add_column :missions, :whitelabel_favicon_filename, :string
    add_column :missions, :whitelabel_favicon_content_size, :string
    add_column :missions, :whitelabel_favicon_content_type, :string
  end
end
