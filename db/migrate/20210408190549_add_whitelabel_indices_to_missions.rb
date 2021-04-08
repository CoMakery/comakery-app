class AddWhitelabelIndicesToMissions < ActiveRecord::Migration[6.0]
  def change
    add_index :missions, :whitelabel_domain
  end
end
