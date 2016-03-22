class TopContributors
  include Interactor

  def call
    projects = context.projects
    n = context.n

    contributors = projects.each_with_object({}) {|project, projects_to_contributors| projects_to_contributors[project] = top_contributors(project, n) }

    context.contributors = contributors
  end

  def top_contributors(project, n)
    all_columns = Authentication.column_names.map{|column| "max(authentications.#{column}) as #{column}"}.join(",")
    project.contributors.
            select("#{all_columns}, sum(award_types.amount) as total_awarded").
            group("authentications.id").
            order("total_awarded desc").
            limit(n).
            to_a.
            sort_by(&:total_awarded).
            reverse
  end
end