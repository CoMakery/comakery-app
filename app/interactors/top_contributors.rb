class TopContributors
  include Interactor

  def call
    projects = context.projects
    contributors = projects.index_with(&:top_contributors)
    context.contributors = contributors
  end
end
