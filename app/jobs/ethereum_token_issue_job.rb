class EthereumTokenIssueJob
  include Sidekiq::Worker
  sidekiq_options queue: 'transaction'

  def perform(award_id, args)
    award = Award.find award_id
    award.update! ethereum_transaction_address: Comakery::Ethereum.token_issue(args)
  end
end
