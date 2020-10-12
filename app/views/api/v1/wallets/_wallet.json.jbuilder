json.call(
  wallet,
  :id,
  :address,
  :source,
  :state,
  :created_at,
  :updated_at
)

json.blockchain wallet._blockchain
json.tokens []
