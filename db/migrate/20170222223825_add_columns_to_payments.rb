class AddColumnsToPayments < ActiveRecord::Migration
  def change
    rename_column :payments, :recipient_id, :payee_id
    rename_column :payments, :amount, :total_value

    add_column :payments, :share_value, :decimal
    add_column :payments, :quantity_redeemed, :integer
    add_column :payments, :transaction_fee, :decimal
    add_column :payments, :total_payment, :decimal
    add_column :payments, :transaction_reference, :text
    add_column :payments, :currency, :string
    add_column :payments, :status, :integer, default: 0
  end
end
