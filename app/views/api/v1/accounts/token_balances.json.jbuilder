json.array! @account.balances.includes(:wallet, :token).map do |balance|
  json.token do
    json.partial! 'api/v1/tokens/token', token: balance.token
  end

  json.blockchain do
    json.address balance.wallet.address
    json.balance balance.base_unit_value
    json.updated_at balance.updated_at
  end

  json.total_received @account.decorate.total_received_in(balance.token)
  json.total_received_and_accepted_in @account.decorate.total_received_and_accepted_in(balance.token)
end
