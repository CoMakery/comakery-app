class TopContributors
  include Interactor

  def call
    projects = context.projects
    contributors = projects.index_with do |project|
      project.top_contributors
    end
    context.contributors = contributors
  end
end
