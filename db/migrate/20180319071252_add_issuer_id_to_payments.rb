class AddIssuerIdToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :issuer_id, :integer
  end
end
