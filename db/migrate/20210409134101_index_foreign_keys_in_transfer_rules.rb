class IndexForeignKeysInTransferRules < ActiveRecord::Migration[6.0]
  def change
    add_index :transfer_rules, :receiving_group_id
    add_index :transfer_rules, :sending_group_id
  end
end
