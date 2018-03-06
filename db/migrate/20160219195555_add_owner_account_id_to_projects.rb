class Account < ActiveRecord::Base; end
class Project < ActiveRecord::Base; end

class AddOwnerAccountIdToProjects < ActiveRecord::Migration[4.2]
  def up
    add_column :projects, :account_id, :integer
    Project.update_all(account_id: Account.first.try(:id))
    change_column :projects, :account_id, :integer, null: false
    add_index :projects, :account_id
  end

  def down
    remove_column :projects, :account_id
  end
end
