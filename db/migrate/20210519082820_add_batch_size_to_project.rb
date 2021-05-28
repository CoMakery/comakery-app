class AddBatchSizeToProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :transfer_batch_size, :integer, default: 1, null: false
  end
end
