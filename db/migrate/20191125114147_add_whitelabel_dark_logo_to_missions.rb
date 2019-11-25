class AddWhitelabelDarkLogoToMissions < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :whitelabel_logo_dark_id, :string
    add_column :missions, :whitelabel_logo_dark_filename, :string
    add_column :missions, :whitelabel_logo_dark_content_size, :string
    add_column :missions, :whitelabel_logo_dark_content_type, :string
  end
end
