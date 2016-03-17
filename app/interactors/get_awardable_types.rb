class GetAwardableTypes
  include Interactor

  def call
    current_account = context.current_account
    project = context.project

    context.awardable_types = current_account ? project.owner_account == current_account ? project.award_types : project.community_award_types : []
  end
end