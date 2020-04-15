class ConvertBlockchainRelatedColumnsToHighPrecisionDecimals < ActiveRecord::Migration[6.0]
  def change
    change_column :account_token_records, :lockup_until, 'decimal(78,0) USING EXTRACT(EPOCH FROM lockup_until)'
    change_column :account_token_records, :balance, :decimal, precision: 78, scale: 0
    change_column :account_token_records, :max_balance, :decimal, precision: 78, scale: 0
    change_column :transfer_rules, :lockup_until, 'decimal(78,0) USING EXTRACT(EPOCH FROM lockup_until)'
    change_column :reg_groups, :blockchain_id, :decimal, precision: 78, scale: 0
  end
end
