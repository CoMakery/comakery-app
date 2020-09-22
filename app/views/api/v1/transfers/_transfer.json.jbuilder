json.call(
  transfer.decorate,
  :id,
  :transfer_type_id,
  :amount,
  :quantity,
  :total_amount,
  :description,
  :transaction_error,
  :status,
  :created_at,
  :updated_at
)

json.account_id transfer.account.managed_account_id
