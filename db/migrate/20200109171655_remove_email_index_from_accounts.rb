class RemoveEmailIndexFromAccounts < ActiveRecord::Migration[6.0]
  def change
    remove_index "accounts", name: "index_accounts_on_lowercase_email"
  end
end
