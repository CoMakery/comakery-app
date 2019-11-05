class AddBlockchainIdToRegGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :reg_groups, :blockchain_id, :bigint
  end
end
