class RemoveAnotherEmailIndexFromAccounts < ActiveRecord::Migration[6.0]
  def change
    remove_index "accounts", name: "index_accounts_on_email"
  end
end
