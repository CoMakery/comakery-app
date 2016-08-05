class CreateEthereumContract
  include Interactor

  def call
    project = context.project

    if project.transitioned_to_ethereum_enabled?
      EthereumTokenContractJob.perform_async(project.id)
      awards = project.award_types.map{ |award_type| award_type.awards.to_a }.flatten
      CreateEthereumAwards.call(awards: awards)
    end
  end
end
