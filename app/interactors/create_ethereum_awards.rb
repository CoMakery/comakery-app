class CreateEthereumAwards
  include Interactor

  def call
    if context.awards
      context.awards.each do |award|
        create_ethereum_award(award)
      end
    elsif context.award
      create_ethereum_award(context.award)
    end
  end

  private

  def create_ethereum_award(award)
    if award.ethereum_ready?
      EthereumTokenIssueJob.perform_async(award.id)
    end
  end
end
