class CreateEthereumAwards
  include Interactor

  def call
    if context.award
      create_ethereum_award(context.award)
    elsif context.awards
      awards.each { |award| create_ethereum_award(award) }
    end
  end

  private

  def create_ethereum_award(award)
    if award.ethereum_issue_ready?
      EthereumTokenIssueJob.perform_async(award.id)
    end
  end
end
