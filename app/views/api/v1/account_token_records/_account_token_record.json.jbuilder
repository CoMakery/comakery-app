json.call(
  account_token_record,
  :id,
  :wallet_id,
  :token_id,
  :max_balance,
  :lockup_until,
  :reg_group_id,
  :account_frozen,
  :status,
  :created_at,
  :updated_at
)

json.managed_account_id account_token_record.account.managed_account_id
