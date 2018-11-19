class AddContributorFormToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :contributor_form, :boolean, default: false
  end
end
