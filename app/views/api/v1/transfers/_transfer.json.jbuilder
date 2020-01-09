json.call(
  transfer.decorate,
  :id,
  :source,
  :amount,
  :quantity,
  :total_amount,
  :description,
  :ethereum_transaction_address,
  :ethereum_transaction_error,
  :status,
  :created_at,
  :updated_at
)

json.account_id transfer.account_id.managed_account_id
