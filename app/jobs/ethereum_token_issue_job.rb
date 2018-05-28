class EthereumTokenIssueJob
  include Sidekiq::Worker
  sidekiq_options queue: 'transaction'

  sidekiq_retry_in do |count|
    30.minutes.to_i * (count + 1) # The current retry count is yielded. The return value of the block must be an integer. It is used as the delay, in seconds.
  end

  def perform(award_id)
    award = Award.find award_id
    return unless award.ethereum_issue_ready?
    project = award.project
    args = {
      recipient: award.decorate.recipient_address,
      amount: award.total_amount,
      proofId: award.proof_id,
      contractAddress: project.ethereum_contract_address
    }

    if project.ethereum_contract_address.blank?
      # on raise, sidekiq will retry the job later:
      raise ArgumentError, "award ##{award.id} belongs to
        project ##{project.id} which has no ethereum contract address (yet)"
    else
      award.update! ethereum_transaction_address: Comakery::Ethereum.token_issue(args)
    end
  end
end
