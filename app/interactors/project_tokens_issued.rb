#TODO: this class can be refactored away
class ProjectTokensIssued
  include Interactor

  def call
    project = context.project

    context.total_tokens_issued = project.awards.sum(:total_amount)
  end
end
