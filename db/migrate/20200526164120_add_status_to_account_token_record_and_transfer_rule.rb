class AddStatusToAccountTokenRecordAndTransferRule < ActiveRecord::Migration[6.0]
  def change
    add_column :account_token_records, :status, :integer, default: 0
    add_column :transfer_rules, :status, :integer, default: 0
  end
end
