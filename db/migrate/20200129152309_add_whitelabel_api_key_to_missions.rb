class AddWhitelabelApiKeyToMissions < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :whitelabel_api_key, :string
  end
end
