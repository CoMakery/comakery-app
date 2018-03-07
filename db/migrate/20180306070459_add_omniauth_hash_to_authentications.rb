class AddOmniauthHashToAuthentications < ActiveRecord::Migration[5.1]
  def change
    add_column :authentications, :email, :string, required: true
    add_column :authentications, :provider_team_id, :string, required: true
  end
end
