class RefactorPayments < ActiveRecord::Migration[5.1]
  def change
    remove_column :payments, :issuer_id, :integer
    rename_column :payments, :payee_id, :account_id
  end
end
