class AddRevenueStreamToProject < ActiveRecord::Migration
  def change
    add_column :projects, :revenue_stream, :text
  end
end
