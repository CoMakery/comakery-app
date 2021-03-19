class AddStatusTimestampsToOreIdAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :ore_id_accounts, :unclaimed_at, :datetime
    add_column :ore_id_accounts, :ok_at, :datetime
  end
end
