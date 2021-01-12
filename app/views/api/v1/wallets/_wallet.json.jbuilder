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
json.provision_tokens(wallet.wallet_provisions.map { |wp| { token_id: wp.token_id, state: wp.state } })
