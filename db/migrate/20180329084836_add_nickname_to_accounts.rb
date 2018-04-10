class AddNicknameToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :nickname, :string
  end
end
