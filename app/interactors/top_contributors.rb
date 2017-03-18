class TopContributors
  include Interactor

  def call
    projects = context.projects
    n = context.n || 5

    contributors = projects.each_with_object({}) do |project, projects_to_contributors|
      projects_to_contributors[project] = top_contributors(project, n)
    end

    context.contributors = contributors
  end

  def top_contributors(project, n)
    all_columns = column_names.map { |column| "max(authentications.#{column}) as #{column}" }.join(", ")
    Authentication.
        select("#{all_columns}, sum(award_total_amount) as total_awarded, max(last_awarded_at) as last_awarded_at").
        from(project.contributors.
            select("#{all_columns}, sum(awards.total_amount) as award_total_amount, max(awards.created_at) as last_awarded_at").
            group("authentications.id, award_types.id"),
             "authentications"
        ).
        group("authentications.id").
        order("total_awarded desc, max(last_awarded_at) desc").
        limit(n).
        to_a
  end

  def column_names
    ["id",
     "account_id",
     "provider",
     "created_at",
     "updated_at",
     "slack_team_name",
     "slack_team_id",
     "slack_user_id",
     "slack_token",
     "slack_user_name",
     "slack_first_name",
     "slack_last_name",
     "slack_team_domain",
     "slack_team_image_34_url",
     "slack_team_image_132_url",
     "slack_image_32_url"
    ]
  end
end