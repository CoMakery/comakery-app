class AddReconciledToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :reconciled, :boolean, default: false
  end
end
