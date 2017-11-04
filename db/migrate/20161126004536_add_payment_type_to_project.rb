class AddPaymentTypeToProject < ActiveRecord::Migration[4.2]
  def up
    add_column :projects, :payment_type, :integer, default: 1 # sets all existing project to "project_token"
    change_column :projects, :payment_type, :integer, default: 0 # future projects default to "royalty_usd"
  end

  def down
    remove_column :projects, :payment_type
  end
end
