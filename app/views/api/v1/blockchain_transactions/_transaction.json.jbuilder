json.call(
  transaction,
  :id,
  :blockchain_transactable_id,
  :blockchain_transactable_type,
  :destination,
  :source,
  :amount,
  :nonce,
  :contract_address,
  :network,
  :tx_hash,
  :tx_raw,
  :status,
  :status_message,
  :created_at,
  :updated_at,
  :synced_at
)

json.blockchain_transactables(
  transaction
    .transaction_batch
    .batch_transactables
    .select(:blockchain_transactable_id, :blockchain_transactable_type)
    .as_json
)
