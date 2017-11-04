class AddOauthDetailsToAccount < ActiveRecord::Migration[4.2]
  def change
    change_column :accounts, :email, :string, null: true
    change_column :accounts, :crypted_password, :string, null: true
    change_column :accounts, :salt, :string, null: true

    add_column :accounts, :provider, :string
    add_column :accounts, :uid, :string
    add_column :accounts, :name, :string
  end
end
