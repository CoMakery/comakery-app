json.array! Token.all do |token|
  record = @account.account_token_records.find_by(token: token)
  next unless record

  json.token do
    json.partial! 'api/v1/tokens/token', token: token
  end

  json.blockchain do
    json.address @account.ethereum_wallet
    json.balance record.balance
    json.max_balance record.max_balance
    json.lockup_until record.lockup_until
    json.account_frozen record.account_frozen
  end

  json.total_received @account.decorate.total_received_in(token)
end
