class AddWhitelabelDataToMissions < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :whitelabel, :boolean
    add_column :missions, :whitelabel_domain, :string
    add_column :missions, :whitelabel_logo_id, :string
    add_column :missions, :whitelabel_logo_filename, :string
    add_column :missions, :whitelabel_logo_content_size, :string
    add_column :missions, :whitelabel_logo_content_type, :string
  end
end
