json.cache! @balances do
  json.array! @balances.map do |balance|
    json.cache! balance do
      json.token do
        json.partial! 'api/v1/tokens/token', token: balance.token
      end

      json.blockchain do
        json.address balance.wallet.address
        json.balance balance.base_unit_value
        json.locked_balance balance.base_unit_locked_value
        json.unlocked_balance balance.base_unit_unlocked_value
        json.lockup_schedule_ids balance.lockup_schedule_ids
        json.updated_at balance.updated_at
      end

      json.total_received @account.decorate.total_received_in(balance.token)
      json.total_received_and_accepted_in @account.decorate.total_received_and_accepted_in(balance.token)
    end
  end
end
