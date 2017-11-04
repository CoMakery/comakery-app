class AddReconciledToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :reconciled, :boolean, default: false
  end
end
