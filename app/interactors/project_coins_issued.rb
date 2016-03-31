class ProjectCoinsIssued
  include Interactor

  def call
    project = context.project

    total_coins_issued = Project.where(id: project.id).
        joins(:awards).
        select("sum(award_types.amount) as total_coins_issued").
        group("projects.id").
        first&.total_coins_issued || 0

    context.total_coins_issued = total_coins_issued
  end
end
