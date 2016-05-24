class EthereumTokenIssueJob
  include Sidekiq::Worker
  sidekiq_options queue: 'transaction'

  def perform(award_id, project_id, args)
    award = Award.find award_id
    args[:contract_address] = Project.find(project_id)&.ethereum_contract_address
    if args[:contract_address]
      award.update! ethereum_transaction_address: Comakery::Ethereum.token_issue(args)
    else
      raise ArgumentError.new("No ethereum contract address found for project")
    end
  end
end
