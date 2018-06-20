class AddCountryToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :country, :string
    add_column :accounts, :date_of_birth, :date
  end
end
