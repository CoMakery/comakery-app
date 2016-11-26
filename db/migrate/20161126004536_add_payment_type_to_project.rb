class AddPaymentTypeToProject < ActiveRecord::Migration
  def change
    add_column :projects, :payment_type, :integer, default: 1 # sets all existing project to "project_coin"
    change_column :projects, :payment_type, :integer, default: 0 # future projects default to "royalty_usd"
  end
end
