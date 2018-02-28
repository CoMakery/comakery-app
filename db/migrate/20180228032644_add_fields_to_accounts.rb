class AddFieldsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :first_name, :string
    add_column :accounts, :last_name, :string
    add_column :accounts, :image, :string
  end
end
