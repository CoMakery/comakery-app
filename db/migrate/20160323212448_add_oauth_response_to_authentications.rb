class AddOauthResponseToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :oauth_response, :jsonb
  end
end
