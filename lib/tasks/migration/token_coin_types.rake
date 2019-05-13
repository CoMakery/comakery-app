namespace :migration do
  task update_token_coin_types: [:environment] do
    Token.where.not(ethereum_contract_address: [nil, '']).where(coin_type: [nil, '']).find_each do |token|
      token.update coin_type: Token.coin_types[:erc20]
    end
  end
end
