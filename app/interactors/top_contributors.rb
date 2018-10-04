class TopContributors
  include Interactor

  def call
    projects = context.projects
    contributors = projects.each_with_object({}) do |project, projects_to_contributors|
      projects_to_contributors[project] = project.top_contributors
    end
    context.contributors = contributors
  end
end
