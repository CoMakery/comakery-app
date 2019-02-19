namespace :migration do
  task update_token_ethereum_networks: [:environment] do
    Token.where.not(ethereum_contract_address: [nil, '']).where(ethereum_network: [nil, '']).find_each do |token|
      token.update ethereum_network: Token.ethereum_networks[:main]
    end
  end
end
