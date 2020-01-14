class AddBalanceToAccountTokenRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :account_token_records, :balance, :decimal
  end
end
