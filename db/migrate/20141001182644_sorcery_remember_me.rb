class SorceryRememberMe < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :remember_me_token, :string, :default => nil
    add_column :accounts, :remember_me_token_expires_at, :datetime, :default => nil

    add_index :accounts, :remember_me_token
  end
end
