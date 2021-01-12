json.array! Token.all.with_attached_logo_image do |token|
  record = @account.account_token_records.find_by(token: token)
  next unless record

  json.token do
    json.partial! 'api/v1/tokens/token', token: token
  end

  json.blockchain do
    json.address @account.address_for_blockchain(token._blockchain)
    json.balance record.balance
    json.max_balance record.max_balance.to_s
    json.lockup_until record.lockup_until
    json.account_frozen record.account_frozen
  end

  json.total_received @account.decorate.total_received_in(token)
  json.total_received_and_accepted_in @account.decorate.total_received_and_accepted_in(token)
end
