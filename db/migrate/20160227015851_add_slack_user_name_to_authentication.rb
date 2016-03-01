class Authentication < ActiveRecord::Base; end

class AddSlackUserNameToAuthentication < ActiveRecord::Migration
  def up
    Authentication.destroy_all
    add_column :authentications, :slack_user_name, :string, null: false
  end

  def down
    Authentication.destroy_all
    remove_column :authentications, :slack_user_name
  end
end
