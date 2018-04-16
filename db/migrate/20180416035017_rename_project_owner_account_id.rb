class RenameProjectOwnerAccountId < ActiveRecord::Migration[5.1]
  def change
    rename_column :projects, :owner_account_id, :account_id
  end
end
