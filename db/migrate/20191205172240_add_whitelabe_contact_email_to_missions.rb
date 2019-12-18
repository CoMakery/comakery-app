class AddWhitelabeContactEmailToMissions < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :whitelabel_contact_email, :string
  end
end
