class AddEmailConfirmTokenToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :email_confirm_token, :string
  end
end
