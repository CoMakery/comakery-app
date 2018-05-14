class Account < ActiveRecord::Base; end
class Project < ActiveRecord::Base; end

class AddOwnerAccountIdToProjects < ActiveRecord::Migration[4.2]
  def up
    add_column :projects, :owner_account_id, :integer
    Project.update_all(account_id: Account.first.try(:id))
    change_column :projects, :owner_account_id, :integer, null: false
    add_index :projects, :owner_account_id
  end

  def down
    remove_column :projects, :owner_account_id
  end
end
