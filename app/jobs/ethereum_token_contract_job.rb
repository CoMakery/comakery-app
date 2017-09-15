class EthereumTokenContractJob
  include Sidekiq::Worker
  sidekiq_options queue: 'create_contract'

  def perform(project_id)
    project = Project.find project_id
    ethereum_contract_address = Comakery::Ethereum.token_contract(maxSupply: project.maximum_tokens)
    project.update! ethereum_contract_address: ethereum_contract_address
  end
end
