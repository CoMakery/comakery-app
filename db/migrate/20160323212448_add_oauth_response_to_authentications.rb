class AddOauthResponseToAuthentications < ActiveRecord::Migration[4.2]
  def change
    add_column :authentications, :oauth_response, :jsonb
  end
end
