class EthereumTokenIssueJob
  include Sidekiq::Worker
  sidekiq_options queue: 'transaction'

  def perform(award_id)
    award = Award.find award_id
    project = award.award_type.project
    args = {
      recipient: award.recipient_address,
      amount: award.award_type.amount,
      proofId: award.proof_id,
      contractAddress: project.ethereum_contract_address
    }
    if award.ethereum_contract_and_account?
      award.update! ethereum_transaction_address: Comakery::Ethereum.token_issue(args)
    else
      raise ArgumentError.new("cannot issue ethereum tokens from award ##{award_id}")
    end
  end
end
