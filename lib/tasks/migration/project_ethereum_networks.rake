namespace :migration do
  task update_project_ethereum_networks: [:environment] do
    Project.project_token.where.not(ethereum_contract_address: [nil, '']).find_each do |project|
      project.update ethereum_network: Project.ethereum_networks[:main]
    end
  end
end
