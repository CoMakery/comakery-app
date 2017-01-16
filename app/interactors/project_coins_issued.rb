#TODO: this class can be refactored away
class ProjectCoinsIssued
  include Interactor

  def call
    project = context.project

    context.total_coins_issued = project.awards.sum(:total_amount)
  end
end
