class AddComakeryAdminToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :comakery_admin, :boolean, default: false
  end
end
