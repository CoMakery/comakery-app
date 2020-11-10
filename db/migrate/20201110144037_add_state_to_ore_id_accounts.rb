class AddStateToOreIdAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :ore_id_accounts, :state, :integer, default: 0, null: false
  end
end
