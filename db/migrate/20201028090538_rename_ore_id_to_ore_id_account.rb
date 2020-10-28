class RenameOreIdToOreIdAccount < ActiveRecord::Migration[6.0]
  def change
    rename_table :ore_ids, :ore_id_accounts
    rename_column :wallets, :ore_id_id, :ore_id_account_id
  end
end
