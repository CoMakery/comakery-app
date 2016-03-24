class TopContributors
  include Interactor

  def call
    projects = context.projects
    n = context.n || 5

    contributors = projects.each_with_object({}) { |project, projects_to_contributors| projects_to_contributors[project] = top_contributors(project, n) }

    context.contributors = contributors
  end

  def top_contributors(project, n)
    all_columns = (Authentication.column_names-["oauth_response"]).map { |column| "max(authentications.#{column}) as #{column}" }.join(", ")
    Authentication.
        select("#{all_columns}, sum(award_type_amount) as total_awarded, max(last_awarded_at) as last_awarded_at").
        from(project.contributors.
            select("#{all_columns}, count(awards.id) * award_types.amount as award_type_amount, max(awards.created_at) as last_awarded_at").
            group("authentications.id, award_types.id"),
            "authentications"
        ).
        group("authentications.id").
        order("total_awarded desc, max(last_awarded_at) desc").
        limit(n).
        to_a
  end
end