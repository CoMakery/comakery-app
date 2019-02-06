class AddProfileFieldsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :specialty, :string
    add_column :accounts, :occupation, :string
    add_column :accounts, :linkedin_url, :string
    add_column :accounts, :github_url, :string
    add_column :accounts, :dribble_url, :string
    add_column :accounts, :behance_url, :string
  end
end
