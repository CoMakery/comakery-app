json.call(
  account,
  :id,
  :email,
  :first_name,
  :last_name,
  :nickname,
  :image_url,
  :country,
  :date_of_birth,
  :ethereum_wallet,
  :qtum_wallet,
  :cardano_wallet,
  :bitcoin_wallet,
  :eos_wallet,
  :tezos_wallet,
  :created_at,
  :updated_at
)

json.image_url account.decorate.image_url

json.verification_state account.decorate.verification_state
json.verification_date account.decorate.verification_date
json.verification_max_investment_usd account.decorate.verification_max_investment_usd
