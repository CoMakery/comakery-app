json.call(
  wallet,
  :id,
  :source,
  :status,
  :created_at,
  :updated_at
)

json.blockchain wallet._blockchain
json.tokens []
