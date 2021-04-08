json.call(
  token.decorate,
  :id,
  :name,
  :symbol,
  :network,
  :contract_address,
  :decimal_places,
  :created_at,
  :updated_at
)

json.logo_url token.decorate.logo_url(host: @whitelabel_mission&.whitelabel_domain)
