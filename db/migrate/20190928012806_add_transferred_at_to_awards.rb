class AddTransferredAtToAwards < ActiveRecord::Migration[5.1]
  def change
    add_column :awards, :transferred_at, :datetime
  end
end
