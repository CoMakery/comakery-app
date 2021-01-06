class AddTempPasswordToOreIdAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :ore_id_accounts, :temp_password, :string
  end
end
