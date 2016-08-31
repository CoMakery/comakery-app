class EthereumTokenIssueJob
  include Sidekiq::Worker
  sidekiq_options queue: 'transaction'

  def perform(award_id)
    award = Award.find award_id
    return unless award.ethereum_issue_ready?
    project = award.project
    args = {
      recipient: award.recipient_address,
      amount: award.award_type.amount,
      proofId: award.proof_id,
      contractAddress: project.ethereum_contract_address
    }

    if project.ethereum_contract_address.blank?
      # on raise, sidekiq will retry the job later:
      raise ArgumentError.new("award ##{award.id} belongs to
        project ##{project.id} which has no ethereum contract address (yet)")
    else
      award.update! ethereum_transaction_address: Comakery::Ethereum.token_issue(args)
    end
  end
end
