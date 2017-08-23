class CreateEthereumAwards
  include Interactor

  def call
    if context.award
      create_ethereum_award(context.award)
    elsif context.awards
      context.awards.each { |award| create_ethereum_award(award) }
    end
  end

  private

  def create_ethereum_award(award)
    EthereumTokenIssueJob.perform_async(award.id) if award.ethereum_issue_ready?
  end
end
