namespace :migration do
  task update_project_coin_types: [:environment] do
    Project.project_token.where.not(ethereum_contract_address: [nil, '']).where(coin_type: [nil, '']).find_each do |project|
      project.update_columns coin_type: Project.coin_types[:erc20]
    end
  end
end
