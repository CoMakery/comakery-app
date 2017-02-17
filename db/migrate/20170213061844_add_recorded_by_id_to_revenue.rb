class AddRecordedByIdToRevenue < ActiveRecord::Migration
  def change
    add_column :revenues, :recorded_by_id, :integer
  end
end
