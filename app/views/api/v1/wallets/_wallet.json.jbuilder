json.call(
  wallet,
  :id,
  :name,
  :address,
  :primary_wallet,
  :source,
  :state,
  :created_at,
  :updated_at
)

json.blockchain wallet._blockchain
json.provision_tokens(wallet.wallet_provisions.map { |wp| { token_id: wp.token_id, state: wp.state } })
