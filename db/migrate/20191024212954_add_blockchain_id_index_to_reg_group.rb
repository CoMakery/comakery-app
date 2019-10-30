class AddBlockchainIdIndexToRegGroup < ActiveRecord::Migration[6.0]
  def change
    add_index :reg_groups, :blockchain_id
  end
end
