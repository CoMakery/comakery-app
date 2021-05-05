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
  transaction.blockchain_transactables.select(:id).map { |bt| { id: bt.id, type: bt.class.name } }
)
