class AddRevenueSharingEndDate < ActiveRecord::Migration
  def change
    add_column :projects, :revenue_sharing_end_date, :datetime
  end
end
