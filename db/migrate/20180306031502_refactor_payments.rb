class RefactorPayments < ActiveRecord::Migration[5.1]
  def change
    rename_column :payments, :payee_id, :account_id
  end
end
